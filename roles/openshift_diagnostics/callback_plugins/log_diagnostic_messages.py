from ansible.plugins.callback import CallbackBase
from ansible.utils.display import Display
from ansible import constants as C

import json

class CallbackModule(CallbackBase):

    CALLBACK_VERSION = 2.0
    CALLBACK_NAME = "dump_log_diagnostic_messages"
    _levels = {
            0: C.COLOR_DEBUG,
            1: None,
            2: C.COLOR_VERBOSE,
            3: C.COLOR_WARN,
            4: C.COLOR_ERROR}

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.display = Display()

    def log(self, result):
        if type(result) == type(dict()):
            if 'msg' in result.keys():
                msg = result['msg']
                if msg.startswith('dict'):
                    message = eval(msg)
                    self.display.display("\n"+message['msg']+"\n",color=self._levels[message['diag_level']])

    def runner_on_ok(self, host, result):
        pass
    def v2_runner_item_on_ok(self, result):        
        self.log(result._result)

