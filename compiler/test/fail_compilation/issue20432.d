struct ExistenceChecker
{
    bool delegate() checkExistenceFn;
}

ExistenceChecker makeExistenceChecker(string gemName)
{
    return ExistenceChecker(() => gemName == "dummy");
}

enum checker = makeExistenceChecker("test");
