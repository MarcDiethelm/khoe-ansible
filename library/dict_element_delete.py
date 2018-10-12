#!/usr/bin/python

DOCUMENTATION = '''
---
module: github_repo
short_description: Delete an element from a dict by key
'''

EXAMPLES = '''
- name: Delete element dict
  dict_element_delete:
    dict: dictname
    key: "key"
  register: result
'''

from ansible.module_utils.basic import AnsibleModule


def work(d, key):

    del d[key]
    return d


def main():

    module_args = {
        "dict": {"required": True, "type": "dict"},
        "key": {"required": True, "type": "str"},
    }

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    d = work(module.params['dict'], module.params['key'])

    result = dict(
        changed=False,
        dict=d,
    )


    module.exit_json(**result)

    # if not is_error:
    #     module.exit_json(changed=has_changed, meta=result)
    # else:
    #     module.fail_json(msg="Error deleting repo", meta=result)


if __name__ == '__main__':
    main()
