module.exports = {
  '**/*.ts': (filenames) => {
    const files = filenames.join(' ');
    return [
      `npx eslint --fix ${files}`,
      `npx prettier --write ${files}`,
    ];
  },
  '**/*.json': (filenames) => {
    const files = filenames.join(' ');
    return [`npx prettier --write ${files}`];
  },
  '**/*.md': (filenames) => {
    const files = filenames.join(' ');
    return [`npx prettier --write ${files}`];
  },
};
