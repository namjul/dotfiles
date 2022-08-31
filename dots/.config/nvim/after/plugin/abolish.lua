local has_abolish = pcall(require, 'abolish')

if not has_abolish then
  return
end

vim.cmd([[
  Abolish teh the
  Abolish functoin function
  Abolish fucnton function
  Abolish fucntion function
  Abolish fuction function
  Abolish sord sort
]])
