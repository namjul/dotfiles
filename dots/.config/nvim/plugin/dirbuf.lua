local util = require('namjul.utils')

util.var.g({
  loaded_netrwPlugin = 1,
})

require("dirbuf").setup {
    hash_padding = 2,
    show_hidden = true,
    sort_order = "directories_first",
    write_cmd = "DirbufSync",
}
