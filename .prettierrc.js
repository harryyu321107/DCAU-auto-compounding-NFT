module.exports = {
  overrides: [
    {
      files: "*.sol",
      options: {
        bracketSpacing: false,
        printWidth: 130,
        tabWidth: 4,
        useTabs: false,
        singleQuote: false,
        explicitTypes: "always",
      },
    },
    {
      files: "*.ts",
      options: {
        printWidth: 145,
        singleQuote: true,
        trailingComma: "none"
      },
    }
  ],
}
