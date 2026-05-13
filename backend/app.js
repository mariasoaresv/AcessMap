const express = require('express');
const cors = require('cors');
const db = require('./config/db');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.send('Backend do AcessMap funcionando!');
});

app.get('/teste', (req, res) => {
    res.send('Rota teste funcionando!');
});

app.get('/usuarios', (req, res) => {

    const sql = 'SELECT * FROM usuarios';

    db.query(sql, (erro, resultado) => {

        if (erro) {
            console.log(erro);

            res.status(500).json({
                erro: 'Erro ao buscar usuários'
            });

            return;
        }

        res.json(resultado);

    });

});

app.listen(3000, () => {
    console.log('Servidor rodando na porta 3000');
});