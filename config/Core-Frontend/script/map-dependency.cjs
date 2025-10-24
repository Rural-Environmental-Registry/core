const fs = require('fs');
const packageJsonPath = './package.json';
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
packageJson.dependencies['dpg-mapa'] = 'file:./Map-Component';
fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));