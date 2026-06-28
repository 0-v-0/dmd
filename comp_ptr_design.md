# DMD 压缩指针（Compressed Pointers）支持设计方案

## 1. 概述

### 1.1 动机

在 64 位平台上，指针占用 8 字节。对于大量使用指针的应用（如类引用、动态数组、关联数组等），指针本身可能消耗显著的内存带宽和缓存容量。

JVM 的压缩 OOPs（Ordinary Object Pointers）技术证明：当堆大小 < 32 GB 时，将 64 位引用压缩为 32 位可带来性能收益——减少内存占用、改善缓存局部性、降低 GC 压力。

### 1.2 与 JVM 的关键差异

D 是系统级语言，与 Java 有本质区别：

| 方面 | Java | D |
|------|------|---|
| 指针种类 | 仅对象引用 | 类引用、`T*` 指针、数组 slice、委托、关联数组、`void*` |
| 指针运算 | 不允许 | 允许（`p + offset`） |
| 内存模型 | GC-only | GC + 手动 + `malloc`/`free` 混合 |
| 内联汇编 | 无 | 有 |
| 精确类型信息 | 全精确 | 保守/精确可切换 |

因此，DMD 的压缩指针必须设计为**可选的、增量的**，不能破坏系统编程能力。

## 2. 设计目标

1. **减少 GC 托管堆中指针的内存占用**：类引用、GC 分配的结构体/数组中的指针字段
2. **与非 GC 代码兼容**：`malloc` 分配的内存、外部库仍使用原生指针
3. **渐进式启用**：按模块或按类型粒度选择
4. **最小侵入性**：不破坏现有 ABI，不改变语言语义
5. **性能可预测**：编码/解码开销小于内存带宽收益

## 3. 编码方案

### 3.1 选择：基地址 + 移位（Base + Shift）

参考 JVM 方案，采用 **堆基地址 + 3 位左移**：

```
compressed_ptr = (native_ptr - heap_base) >> 3
native_ptr     = (compressed_ptr << 3) + heap_base
```

- 移位量 3 位 = 8 字节对齐
- 32 位无符号压缩指针可寻址 32 GB 堆
- 空指针：`compressed_ptr = 0` → `native_ptr = heap_base` → 约定 `heap_base` 不用做有效地址

**为什么不选纯移位（zero-based）：**

- D 的 GC 堆不一定映射在地址 0 附近（特别是在 Windows 上）
- 基地址方案更通用

### 3.2 编码/解码开销

每次从内存加载压缩指针需要：

```asm
; 解码：加载 → 左移 3 → 加基地址
mov  eax, [mem]      ; 32 位加载
shl  rax, 3
add  rax, heap_base
```

每次存储需要：

```asm
; 编码：减基地址 → 右移 3 → 存储
sub  rax, heap_base
shr  rax, 3
mov  [mem], eax      ; 32 位存储
```

每指针操作比原生多 2-3 条指令，但节省 4 字节内存/指针 + 减少缓存缺失。

### 3.3 堆基地址管理

GC 在初始化时保留一块 32 GB 的虚拟地址空间（`VirtualAlloc`/`mmap` 保留但不提交），基地址在该区域中分配第一个 pool 时确定。

## 4. 编译器的修改

### 4.1 前端类型系统

#### 4.1.1 新增类型标志 `TYcompressedptr`

在 `compiler/src/dmd/astenums.d` 中新增：

```d
Tcompressedptr,       // 压缩指针类型
```

在 `mtype.d` 中新增 `TypeCompressedPointer` 类：

```d
extern (C++) final class TypeCompressedPointer : TypePointer
{
    // 内部存储为 TYcompressedptr
    // 语义上等同于 TypePointer，但 ABI 大小为 4 字节
    // 读/写时自动编码/解码
}
```

#### 4.1.2 Target 结构体新增字段

在 `compiler/src/dmd/target.d` 的 `Target` 结构体中：

```d
struct Target
{
    // ... 现有字段
    bool useCompressedPointers;  /// 是否启用压缩指针（全局开关）
    ubyte compressedPtrSize;     /// 压缩指针大小（通常 4）
    void* heapBase;              /// GC 堆基地址（仅编译时链接符号引用）
}
```

`_init()` 中：`ptrsize` 仍代表原生指针大小（用于 ABI 计算），新增 `compressedPtrSize` 字段。

#### 4.1.3 `hasPointers()` 兼容

`typesem.d` 中的 `hasPointers()`——`TypeCompressedPointer` 同样返回 `true`。

### 4.2 编译器命令行选项

新增 `-compressed-pointers` 开关：

```
-compressed-pointers    若为支持的平台（当前只有x86_64）则启用全局压缩指针模式
-compressed-pointers=on 强制启用全局压缩指针模式
-compressed-pointers=off 禁用（默认）
```

在 `compiler/src/dmd/params.d` / `mars.d` 中添加对应 `Param` 字段。

### 4.3 后端类型系统

#### 4.3.1 新增 `TYcptr`

在 `compiler/src/dmd/backend/ty.d` 中新增：

```d
TYcptr = 0x61,  // compressed pointer（32位，但语义为指针）
TYMAX  = 0x62,  // 更新 MAX
```

在 `ty.d` 的 `_tysize[]` 初始化中：

```d
_tysize[TYcptr] = 4;  // 固定 4 字节
```

#### 4.3.2 `backconfig.d` 修改

`util_set32`/`util_set64` 中设置 `_tysize[TYcptr]`。

### 4.4 粘合层（Glue Layer）

#### 4.4.1 `toctype.d` 的 `visitPointer`

```d
void visitPointer(TypePointer t)
{
    if (target.useCompressedPointers && t.isGCManaged())
        type_cptr(Type_toCtype(t.next));  // 使用 TYcptr
    else
        type_pointer(Type_toCtype(t.next));
}
```

需要新增方法 `TypePointer.isGCManaged()` 判断指针是否指向 GC 堆。

#### 4.4.2 `toobj.d` 的 `write_pointers`

更新指针重定位信息生成，压缩指针字段的偏移量计算变化：

- 指向压缩指针的偏移量：以 `compressedPtrSize`（4 字节）为单位
- 指向原生指针的偏移量：以 `ptrsize`（8 字节）为单位

#### 4.4.3 `todt.d` 的 RTInfo 生成

- 结构体/类的 `xgetRTInfo` 位图生成需要考虑压缩指针字段仅占 4 字节
- 每个 `CompressedPointer` 字段在 bitmaps 中标记为 1 个 slot（而非 1 个 word）

### 4.5 代码生成

#### 4.5.1 x86_64 后端

在 `compiler/src/dmd/backend/x86/` 中新增压缩指针的加载/存储指令生成：

**加载压缩指针并解码为原生指针：**

```asm
mov     r32, [base+offset]    ; 压缩值 → 32位寄存器
shl     r64, 3                ; 左移 3 位
add     r64, heap_base        ; 加堆基地址
```

**存储原生指针编码为压缩指针：**

```asm
sub     r64, heap_base        ; 减堆基地址
shr     r64, 3                ; 右移 3 位
mov     [base+offset], r32    ; 存储 32 位值
```

#### 4.5.2 优化机会

- **内联编码/解码**：若在同一函数中连续加载和存储同一压缩指针，合并编码/解码
- **公共子表达式消除**：对同一基地址的多个压缩指针解码共享 `add heap_base`
- **零扩展消除**：x86_64 的 32 位操作自动清零高 32 位

### 4.6 指针位图生成

在 `compiler/src/dmd/traits.d` 的 `getTypePointerBitmap` 中：

```d
void visitCompressedPointer(TypeCompressedPointer t)
{
    // 压缩指针占 compressedPtrSize 字节，在 bitmap 中用 1 bit 标记
    setpointer(offset);
}
```

## 5. 运行时/GC 的修改

### 5.1 GC 堆初始化

在 `druntime/src/core/internal/gc/impl/conservative/gc.d` 中：

```d
// 新增字段
static void* heapBase;           // 堆基地址
static size_t heapSize;          // 堆大小 (32 GB)
static bool compressedPointers;  // 是否启用压缩指针模式

static void initializeHeapBase()
{
    version (Windows)
        heapBase = VirtualAlloc(null, 32UL * 1024 * 1024 * 1024,
                                MEM_RESERVE, PAGE_NOACCESS);
    else version (Posix)
        heapBase = mmap(null, 32UL * 1024 * 1024 * 1024,
                        PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    // 第一个 pool 从 heapBase 开始分配
}
```

### 5.2 Pool 结构调整

#### 5.2.1 SmallObjectPool

`is_pointer` 位图当前以 `void*.sizeof`（8 字节）为单位标记指针位置。

当启用压缩指针时：
- 小对象分配中的指针字段只占 4 字节
- `is_pointer` 位图单位仍为 `void*.sizeof`（为兼容保守扫描模式）
- 新增 `is_compressed_pointer` 位图，以 `compressedPtrSize` 为单位

**更简洁的方案**：在精确扫描模式下，根据 TypeInfo 的 bitmap 标记直接识别压缩指针位置，GC 在扫描时自动解码。

#### 5.2.2 `setPointerBitmap` 修改

```d
void setPointerBitmap(void* p, size_t s, size_t allocSize,
                       const TypeInfo ti, uint attr) nothrow
{
    // ... 现有逻辑 ...
    auto rtInfo = cast(const(size_t)*)ti.rtInfo();
    if (rtInfo !is rtinfoNoPointers && rtInfo !is rtinfoHasPointers)
    {
        // 检查 rtInfo 中是否标记了压缩指针
        // 如果是，GC 需要解码槽位值再扫描
    }
}
```

rtInfo 返回值需要扩展来标记压缩指针信息。引入新的格式：

```
rtInfo 结构扩展：
bit 0:    是否为压缩RTInfo（1=压缩格式）
bits 1-5: 每元素位图大小（0=原生指针8字节，1=压缩指针4字节）
bits 6+:  现有位图数据
```

实现方式：使用一个额外的 `rtinfoCompressed` 常量来标记 "此类型包含压缩指针"：

```d
// 在 object.d 中新增
enum immutable(void)* rtinfoCompressed = cast(void*)2;
```

### 5.3 GC 扫描逻辑修改

#### 5.3.1 `mark()` 函数修改

在精确扫描模式下，碰到标记为压缩指针的槽位，需要：

```d
if (isCompressedSlot(rng, bitpos))
{
    // 槽位值是压缩指针，需要解码
    ulong compressed = *cast(uint*)rng.pbot;  // 32 位读取
    void* decoded = cast(void*)((compressed << 3) + heapBase);
    p = decoded;
}
else
{
    p = *cast(void**)rng.pbot;  // 原生 64 位读取
}
```

#### 5.3.2 根扫描

栈扫描和全局根扫描保持不变——根以原生指针存储（因为它们是栈上的局部变量，受地址空间布局影响，不压缩）。

### 5.4 新分配接口

在 `core.memory.GC` 中新增：

```d
/// 分配并返回压缩指针
/// 仅在启用压缩指针时有效
T compressedMalloc(T)(size_t size) @trusted
if (isPointer!T || is(T == class))
{
    auto p = GC.malloc(size);
    return cast(T)encode(p);
}
```

## 6. TypeInfo/RTTI 修改

### 6.1 `object.d` 中的 RTInfo

```d
// 现有
enum immutable(void)* rtinfoNoPointers  = null;
enum immutable(void)* rtinfoHasPointers = cast(void*)1;

// 新增
enum immutable(void)* rtinfoCompressed  = cast(void*)2;
```

### 6.2 编译器生成压缩 RTInfo

在 `typinf.d` 的 `genTypeInfo` 中，当启用压缩指针时：

```d
// 为包含压缩指针的类型生成压缩RTInfo标记
if (target.useCompressedPointers && type.hasPointers())
    m_RTInfo = rtinfoCompressed;
else
    m_RTInfo = generateNormalRTInfo(type);
```

当 GC 看到 `rtinfoCompressed` 时，使用解码方式扫描该对象。

## 7. 实现阶段

### Phase 1：基础架构

| 任务 | 文件 | 估算 |
|------|------|------|
| 新增 `-compressed-pointers` 命令行选项 | `mars.d`, `params.d` | 1d |
| `Target` 结构体添加字段 | `target.d` | 0.5d |
| `TypeCompressedPointer` 类 | `mtype.d` | 1d |
| 后端 `TYcptr` 类型 | `backend/ty.d`, `backend/type.d` | 0.5d |

### Phase 2：前端-后端粘合

| 任务 | 文件 | 估算 |
|------|------|------|
| `toctype.d` 的 `visitPointer` 分派 | `glue/toctype.d` | 1d |
| `e2ir.d` 压缩指针 IR 生成 | `glue/e2ir.d` | 2d |
| `todt.d` RTInfo 生成适配 | `glue/todt.d` | 2d |
| `toobj.d` 指针重定位适配 | `glue/toobj.d` | 1d |

### Phase 3：x86_64 代码生成

| 任务 | 文件 | 估算 |
|------|------|------|
| 压缩指针加载/存储编码/解码指令 | `backend/x86/cg.d` | 3d |
| 函数参数传递时压缩指针 ABI 处理 | `backend/x86/cg.d` | 2d |
| 公共子表达式优化 | `backend/cgcs.d` | 2d |
| 寄存器分配适配 | `backend/x86/reg.d` | 2d |

### Phase 4：GC/运行时支持

| 任务 | 文件 | 估算 |
|------|------|------|
| 堆基地址保留与初始化 | `impl/conservative/gc.d` | 2d |
| 压缩指针位图集成 | `impl/conservative/gc.d` | 3d |
| `mark()` 精确扫描解码 | `impl/conservative/gc.d` | 2d |
| `setPointerBitmap` 适配 | `impl/conservative/gc.d` | 1d |

### Phase 5：测试与稳定化

| 任务 | 估算 |
|------|------|
| 单元测试：编译期类型大小验证 | 2d |
| 集成测试：含压缩指针的 GC 分配释放 | 3d |
| 性能基准测试 | 2d |
| 回归测试（保守模式、精确模式） | 3d |

**总计**：约 8 周

## 8. 风险和未决问题

### 8.1 ABI 兼容性

- 启用压缩指针后，类的内存布局发生变化（引用字段从 8B → 4B）
- 需要确保用 `extern(C)`、`extern(C++)` 链接的外部代码不受影响
- 新增 `extern(D, compressed)` 链接类型？

### 8.2 内联汇编与 `void*` 互转

- D 允许 `cast(void*)classRef` 和 `cast(MyClass)voidPtr`
- 若类引用内部用压缩指针，`cast(void*)` 需要解码
- **方案**：类型系统中 `void*` 始终原生，类引用压缩仅在内存中，在寄存器中始终解码

### 8.3 `.offsetof` 与 `__traits(classInstanceSize)`

- 类的字段偏移量因压缩指针大小变化
- 编译器需要根据 `compressedPtrSize` 计算正确偏移

### 8.4 并发

- 堆基地址在 GC 初始化时一旦确定即不变，不存在并发竞争
- 编码/解码在用户线程执行，GC 暂停时扫描

### 8.5 关联数组与动态数组

- 动态数组是 `(ptr, length)`，ptr 是原生指针，不受影响
- 关联数组内部哈希表包含指针，需要评估

### 8.6 调试体验

- 调试器看到的内存中类引用是压缩值（看起来像小整数），需要调试器扩展
- 可通过 `-compressed-pointers=off` 在调试构建中禁用

## 9. 备选方案与讨论

### 9.1 仅压缩类引用（保守方案）

最接近 JVM：只对 `class` 类型引用启用压缩。优势是改动范围小、对现有代码影响小。

### 9.2 使用 `@compressed` UDA

用户按类型显式标记：

```d
@compressed class MyClass { ... }
struct Foo { @compressed MyClass ref; }
```

编译器仅对标记的类型启用压缩。优势是用户精确控制，但增加了语言复杂度。

### 9.3 在 LDC/GDC 上优先实验

DMD 的 x86_64 后端较老，可在 LDC（LLVM 后端）或 GDC（GCC 后端）上先验证方案，然后移植到 DMD。

---

## 附录：关键文件与 API 清单

| 组件 | 文件 | 关键符号 |
|------|------|---------|
| 前端类型系统 | `compiler/src/dmd/mtype.d` | `TypePointer`, `TypeCompressedPointer` |
| 类型枚举 | `compiler/src/dmd/astenums.d` | `Tpointer`, `Tcompressedptr` |
| 目标抽象 | `compiler/src/dmd/target.d` | `Target.ptrsize`, `Target.useCompressedPointers` |
| 指针存在检查 | `compiler/src/dmd/typesem.d` | `hasPointers()` |
| 指针位图 | `compiler/src/dmd/traits.d` | `getTypePointerBitmap()` |
| 类型转后端 | `compiler/src/dmd/glue/toctype.d` | `visitPointer()` |
| 后端类型 | `compiler/src/dmd/backend/ty.d` | `TYnptr`, `TYcptr`, `_tysize[]` |
| 后端配置 | `compiler/src/dmd/backend/backconfig.d` | `util_set32()`, `util_set64()` |
| x86 代码生成 | `compiler/src/dmd/backend/x86/cg.d` | 加载/存储指令 |
| GC API | `druntime/import/core/memory.d` | `GC.malloc()` |
| GC 实现 | `druntime/src/core/internal/gc/impl/conservative/gc.d` | `Pool`, `mark()`, `setPointerBitmap()` |
| TypeInfo | `druntime/import/object.d` | `rtInfo()`, `rtinfoNoPointers`, `rtinfoHasPointers`, `rtinfoCompressed` |
| GC 接口 | `druntime/import/core/gc/gcinterface.d` | `GC` 接口 |
| 构建 | `compiler/src/osmodel.mak` | OS/MODEL/ARCH 检测 |
| 构建定义 | `dub.sdl` | compiler/root/lexer/parser/frontend 子包 |
