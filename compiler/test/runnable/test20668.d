// COMPILE_SEPARATELY:
// EXTRA_SOURCES: imports/test20668a.d imports/test20668b.d

import imports.test20668a;
import imports.test20668b;

void main()
{
    GenericEvent!int lhs;
    GenericEvent!int rhs;
    Holder holderLhs;
    Holder holderRhs;
    ComplexHolder complexHolderLhs;
    ComplexHolder complexHolderRhs;

    assert(lhs == rhs);
    assert(same(lhs, rhs));
    assert(sameHolder(holderLhs, holderRhs));
    assert(complexHolderLhs == complexHolderRhs);
    assert(sameComplexHolder(complexHolderLhs, complexHolderRhs));
}
