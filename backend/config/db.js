const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '95ave1995',
    database: 'acessmap'
});

db.connect((erro) => {
    if (erro) {
        console.error('Erro ao conectar no MySQL:', erro);
        return;
    }

    console.log('Conectado ao banco MySQL!');
});

module.exports = db;