# Revisão do dia 03/06/2025
O script SQL está incompleto.

As tarefas estão abaixo:

---

🧠 Minimundo: Sistema de Locadora de Filmes
A empresa CineLocadora realiza o aluguel de filmes para clientes cadastrados. Os clientes podem alugar vários filmes, e cada aluguel pode conter vários itens. A locadora deseja manter um controle sobre:

Seus clientes.

O catálogo de filmes disponíveis.

Os aluguéis feitos pelos clientes.

Os itens de cada aluguel, especificando os filmes alugados, a quantidade e o valor pago.

Além disso, a empresa deseja visualizar:

Os clientes que mais alugaram.

Os filmes que foram mais alugados.

O valor total arrecadado por aluguel.

Um ranking dos filmes mais alugados.

📦 Entidades e Atributos
1. Clientes
id (PK)

nome

email

telefone

2. Filmes
id (PK)

titulo

categoria

preco_aluguel

estoque

3. Alugueis
id (PK)

id_cliente (FK → Clientes.id)

data_aluguel

valor_total

4. ItensAluguel
id (PK)

id_aluguel (FK → Alugueis.id)

id_filme (FK → Filmes.id)

quantidade

preco_unitario

📌 Conteúdos de revisão
Conteúdo	Aplicação
Criação de tabelas	CREATE TABLE, chaves primárias e estrangeiras
Inserção de dados	INSERT INTO com múltiplos registros
Consultas simples	SELECT, WHERE, ORDER BY, LIMIT
Funções agregadas	SUM(), AVG(), MAX(), COUNT()
Joins	INNER JOIN, LEFT JOIN, JOIN múltiplas tabelas
Subqueries	Clientes que alugaram acima da média
Views	Filmes mais alugados, clientes ativos
Procedures	Cadastrar cliente, calcular valor de um aluguel
Triggers	Atualizar estoque ao registrar item de aluguel
Transações	Registrar aluguel e itens com segurança usando START TRANSACTION
Índices e performance	Criar índice em email ou titulo para facilitar buscas


🔹 Básicas (nível inicial):
Crie a tabela Filmes com os seguintes campos:

id (chave primária), titulo, categoria, preco_aluguel, estoque.

Insira três filmes na tabela Filmes.

Crie uma consulta que retorne todos os filmes da categoria "Ação".

Liste os nomes e e-mails de todos os clientes.

Mostre os filmes com preço de aluguel acima da média.
Dica: use subquery com AVG()

🔹 Intermediárias (JOINS e funções):
Crie uma consulta que mostre o nome do cliente, a data do aluguel e o valor total de cada aluguel.

Liste todos os filmes que foram alugados ao menos uma vez, com a quantidade total de vezes alugado.
Dica: JOIN + GROUP BY

Crie uma VIEW chamada RankingFilmes que mostre os filmes mais alugados, com base na soma das quantidades.

🔹 Avançadas:
Crie uma Stored Procedure que receba o ID de um aluguel e calcule o valor total com base nos itens.

Crie uma Trigger que, ao inserir um item de aluguel, diminua o estoque do filme correspondente.

Crie uma transação que:

Insere um novo aluguel

Insere dois itens de aluguel

Calcula e atualiza o valor total do aluguel

🧩 Desafio Final
Crie uma procedure chamada cadastrarAluguelCompleto que:

Receba o ID do cliente, e uma lista de IDs de filmes e quantidades.

Insira o aluguel na tabela Alugueis.

Insira os itens na tabela ItensAluguel.

Atualize o estoque de cada filme.

Calcule o valor total do aluguel e atualize.
