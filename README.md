# ntangle-notebook.nvim

Jupyter front written in Lua. It will be made compatible with ntangle.nvim.

**WIP**

![](https://github.com/jbyuki/gifs/blob/main/2022-06-29%2016-44-44_Trim.gif?raw=true)


Test
----

* Open qtconsole with `--JupyterWidget.include_other_output=True`. This will show output from other frontends.
* In qtconsole, type `%connect_info`.
Output should be similar to this:
```json
{
  "shell_port": 60142,
  "iopub_port": 60143,
  "stdin_port": 60144,
  "control_port": 60146,
  "hb_port": 60145,
  "ip": "127.0.0.1",
  "key": "9f3a32bf-c538346fd9562326bc2bd1fa",
  "transport": "tcp",
  "signature_scheme": "hmac-sha256",
  "kernel_name": ""
}
```

* Connect with `lua require"ntangle-notebook".connect(SHELL_PORT, KEY)` where `SHELL_PORT` and `KEY` are taken from the connect infos.

* Execute code with `lua require"ntangle-notebook".send_code([[print("hello world")]])`

* Note: It's possible to specify the jupyter runtime directory in `g:ntangle_notebook_runtime_dir` so that the SHELL_PORT and KEY argument do not need to be provided. It will connect to the latest started kernel.

Autoscroll
----------

There might be some issues with this. A definite solution was not found but changing in `qtconsole/console_widget.py`.

```python
should_autoscroll = self._viewport_at_end()
```

to 

```python
should_autoscroll = True # self._viewport_at_end()
```

gives a delayed autoscroll at least.
