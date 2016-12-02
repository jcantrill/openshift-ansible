def main():
    module = AnsibleModule(
        argument_spec=dict(
            messages={"required": True, "type": "list"},
            diag_level={"required": True, "type": "int"},
            msg={"required": True, "type": "str"}
        )
    )
    try:
        messages = module.params["messages"]
        messages = messages + [{"diag_level" : module.params["diag_level"], "msg":module.params["msg"]}]
        module.exit_json(
            ansible_facts = {"openshift_diagnostic_messages" : messages}
        )
    except Exception as e:
        module.fail_json(msg=str(e))

from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
