Este documento serve como guia para manter nosso código organizado e seguro. Como estamos no processo de desenvolvimento, não trabalhamos diretamente na main:

Como rodar o projeto
Clone o repositório:

O projeto utiliza uma chave de API do Mapbox (é necessário criar uma conta no mapbox para adiquirir a chave). Por segurança, eu não subi a chave para o GitHub.

Na pasta raiz, crie um arquivo chamado .env e copie o conteúdo abaixo para dentro dele (Substitua sua_chave_aqui pela sua própria chave obtida no Mapbox.):
MAPBOX_ACCESS_TOKEN=sua_chave_aqui

Após isso, coloque o arquivo .env no gitignore para não ser publicado.




Para evitar conflitos e não quebrar o código que já está funcionando, usamos o sistema de Branches.

1. É necessário garantir que a branch está atualizada;

2. Crie sua Branch
Nunca suba código direto na main. Crie uma branch para a sua funcionalidade ou otimização(ex: login, mapas, design):

3. Envie para o GitHub (registrando o committ) Vamos juntar as partes quando estiver tudo funcionando
