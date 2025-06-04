CREATE DATABASE IF NOT EXISTS cinelocadora_db;

USE cinelocadora_db;

CREATE TABLE Clientes(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nome VARCHAR(100) NOT NULL,
	email VARCHAR(100) NOT NULL,
	telefone VARCHAR(15)
);

CREATE TABLE Filmes(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco_aluguel DECIMAL(10,2) NOT NULL,
    estoque INT
);

CREATE TABLE Alugueis(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    id_cliente INT,
    data_aluguel DATE,
    valor_total DECIMAL(10,2)
);

CREATE TABLE ItensAluguel(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	id_aluguel INT,
    id_filme INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2)
);

-- Preparo das tabelas
-- Clientes
INSERT INTO Clientes (nome, email, telefone) VALUES
('Henrique', 'henrique@gmail.com', '21987654321'),
('Roberto', 'roberto@protonmail.com', '21998765432'),
('Miranda', 'miranda@outlook.com', '21912345678');

-- Filmes
INSERT INTO Filmes(titulo, categoria, preco_aluguel, estoque)
VALUES
('O Filme de Ação de Todos os Tempos', 'Ação', 15.00, 15),
('O Filme Dramático de Todos os Tempos', 'Drama', 15.00, 15),
('O Filme Hilário de Todos os Tempos', 'Comédia', 25.00, 8); -- Esse filme tem demanda.

-- Alugueis
INSERT INTO Alugueis(id_cliente, data_aluguel, valor_total) VALUES
(1, '2025-06-01', 30.00),  -- Henrique
(2, '2025-06-02', 15.00),  -- Roberto
(3, '2025-06-03', 25.00);  -- Miranda

-- ItensAluguel
INSERT INTO ItensAluguel(id_aluguel, id_filme, quantidade, preco_unitario) VALUES
(1, 1, 1, 15.00),  -- Aluguel 1: O Filme de Ação de Todos os Tempos
(1, 3, 1, 25.00),  -- Aluguel 1: O Filme Hilário de Todos os Tempos
(2, 2, 1, 15.00),  -- Aluguel 2: O Filme Dramático de Todos os Tempos
(3, 3, 1, 25.00);  -- Aluguel 3: O Filme Hilário de Todos os Tempos

/* Básicas (nível inicial): */

-- Criar tabela filmes:
-- Já foi feito. Está na linha 12.

-- Insira três filmes na tabela Filmes.
-- Já foi feito. Está na linha 43.

-- Crie uma consulta que retorne todos os filmes da categoria "Ação".
SELECT * FROM Filmes
WHERE categoria = 'Ação';

-- Liste os nomes e e-mails de todos os clientes.
SELECT nome, email FROM Clientes;

-- Mostre os filmes com preço de aluguel acima da média.
-- Dica: use subquery com AVG()
SELECT * FROM Filmes
WHERE preco_aluguel > (SELECT AVG(preco_aluguel) FROM Filmes);

/* Intermediárias (JOINS e funções): */

-- Crie uma consulta que mostre o nome do cliente, a data do aluguel e o valor total de cada aluguel.
SELECT Clientes.nome, Alugueis.data_aluguel, Alugueis.valor_total
FROM Alugueis
INNER JOIN Clientes ON Alugueis.id_cliente = Clientes.id;

-- Liste todos os filmes que foram alugados ao menos uma vez, com a quantidade total de vezes alugado.
-- Dica: JOIN + GROUP BY
SELECT Filmes.titulo, COUNT(ItensAluguel.id) AS 'Vezes alugado'
FROM Filmes
INNER JOIN ItensAluguel ON Filmes.id = ItensAluguel.id_filme
GROUP BY Filmes.titulo;

-- Crie uma VIEW chamada RankingFilmes que mostre os filmes mais alugados, com base na soma das quantidades.
CREATE VIEW RankingFilmes AS
SELECT Filmes.titulo, COUNT(ItensAluguel.id) AS 'Vezes alugado'
FROM Filmes
INNER JOIN ItensAluguel ON Filmes.id = ItensAluguel.id_filme
GROUP BY Filmes.titulo
ORDER BY COUNT(ItensAluguel.id) DESC;

SELECT * FROM RankingFilmes; -- Chamar VIEW

/* Avançadas */

-- Crie uma Stored Procedure que receba o ID de um aluguel e calcule o valor total com base nos itens.
DELIMITER //

CREATE PROCEDURE CalcularValorTotal(IN aluguel_id INT)
BEGIN
	SELECT SUM(preco_unitario) as valor_total FROM ItensAluguel -- Como o objetivo é apenas retornar o total, selecionamos a soma dos preços unitários em ItensAluguel.
    WHERE id_aluguel = aluguel_id; -- Os itens são do mesmo Aluguel (da table Alugueis).
END //

DELIMITER ;

DROP PROCEDURE CalcularValorTotal;

CALL CalcularValorTotal(1); -- Chamar PROCEDURE para testar. O Aluguel de ID 1 é o que possui dois itens alugados.

-- Crie uma Trigger que, ao inserir um item de aluguel, diminua o estoque do filme correspondente.
DELIMITER //

CREATE TRIGGER ReduzirEstoque
AFTER INSERT ON ItensAluguel -- Diferentemente do código da aula, estamos checando por INSERTs na tabela ItensAluguel
FOR EACH ROW
BEGIN
	UPDATE Filmes
    SET estoque = estoque - NEW.quantidade -- Note que esses NEW se referem as NOVAS entradas (para cada linha, ou, em inglês, FOR EACH ROW)
    WHERE id = NEW.id_filme; -- do item que estamos checando, ou seja, o que apareceu de NOVO, DEPOIS do INSERT EM ItensAluguel.
    -- Também é importante reduzir por quantidade porque sabemos que o usuário é vil ele pode alugar 10 filmes iguais igual um maníaco.
END //

DELIMITER ;
-- O trigger acima é suficiente, mas ele pode falhar porque, antes de ser executado, ele não checa se o estoque é suficiente,
-- mas ele não pode fazer isso porque ele é executado DEPOIS (AFTER).
-- Para que ele execute esse check ANTES, um TRIGGER que busca por ações ANTERIORES (BEFORE) deve ser criado.

-- Bônus:
DELIMITER //

CREATE TRIGGER ImpedirEstoqueNegativo -- Similar a versão do repositório da aula
BEFORE UPDATE ON Filmes -- Ele será executado ANTES (BEFORE) do TRIGGER ATUALIZAR Filmes
FOR EACH ROW
BEGIN
    IF NEW.estoque < 0 THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Estoque não pode ser negativo.';
	END IF;
END //

DELIMITER ; 

-- Criar uma transação que:
-- Insere um novo aluguel
-- Insere dois itens de aluguel
-- Calcula e atualiza o valor total do aluguel

-- Para isso, podemos utilizar o AtualizarValorPedidoItem da aula passada, só é necessário modificá-lo.
DELIMITER //

CREATE TRIGGER AtualizarValorAluguel
AFTER INSERT ON ItensAluguel
FOR EACH ROW
BEGIN
	DECLARE total DECIMAL (10,2); -- DECLARE declara uma variável local
								  -- @ declara uma variável por sessão ou usuário. Não é útil aqui.
    
    SELECT SUM(quantidade * preco_unitario) INTO total -- INTO (EM ou DENTRO), coloca o resultado DENTRO de total.
    FROM ItensAluguel
    WHERE id_aluguel = NEW.id_aluguel; -- Naturalmente, um id de aluguel só irá existir em ItensAluguel se um aluguel existe (FOREIGN KEY)
    
    UPDATE Alugueis
    SET valor_total = total -- total sendo a nossa variável
    WHERE id = NEW.id_aluguel;
END //

DELIMITER ;

-- Verificar alguns valores...
SELECT * FROM Alugueis;
SELECT * FROM ItensAluguel;
SELECT * FROM Filmes; -- O estoque também será reduzido.

-- Criando um novo aluguel
INSERT INTO Alugueis(id_cliente, data_aluguel, valor_total) VALUES
(1, '2025-05-26', 0.00);  -- Note que o valor_total está vazio, mas será automaticamente preenchido pelo TRIGGER acima.

-- Inserir os novos valores
INSERT INTO ItensAluguel(id_aluguel, id_filme, quantidade, preco_unitario) VALUES
(4, 1, 1, 15.00),  -- Aluguel: O Filme de Ação de Todos os Tempos
(4, 3, 1, 25.00);  -- Aluguel: O Filme Hilário de Todos os Tempos

/* Desafio Final */

DELIMITER //

CREATE PROCEDURE CadastrarAluguelCompleto(
	IN id_cliente INT,
    IN id_filme INT,
    IN quantidade INT
)

BEGIN
	INSERT INTO Alugueis(id_cliente, data_aluguel, valor_total)
    VALUES (id_cliente, NOW(), 0); -- Será zero, pois é automaticamente atualizado.
    
    INSERT INTO ItensAluguel
    
END //


DELIMITER ;



