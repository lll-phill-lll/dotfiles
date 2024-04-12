set auto-load safe-path /
set history save on

set print pretty on
set print object on


python
import sys
sys.path.insert(0, '/home/mfilitov/libcxx-pretty-printers/src')
from libcxx.v1.printers import register_libcxx_printers
register_libcxx_printers(None)
end

