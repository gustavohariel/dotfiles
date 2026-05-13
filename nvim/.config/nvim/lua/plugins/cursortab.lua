return {
  "leonardcser/cursortab.nvim",
  build = "cd server && go build -o cursortab",
  config = function()
    require("cursortab").setup({
      provider = {
        type = "sweepapi",
        api_key_env = "SWEEPAPI_TOKEN",
      },
    })
  end,
}
