module mydll;

import core.attribute;

export:

__gshared int visibleValue = 7;
@hidden __gshared int hiddenValue = 11;
