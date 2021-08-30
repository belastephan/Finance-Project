
-- Definindo os melhores clientes do ponto de vista das informações de empréstimos, ou seja, aqueles que concluiram o contrato sem problemas--

SELECT
*
FROM loan

CREATE TEMPORARY TABLE best_clients_loan AS 
SELECT
	status, account_id, sum(amount) AS AMOUNT
	FROM loan
    WHERE status = "A"
    GROUP BY account_id, status
	ORDER BY sum(amount) DESC;
    
    DROP TEMPORARY TABLE best_clients_loan
    
SELECT
count(account_id)
FROM best_clients_loan

-- Relacionando Temp best_clients_loan com Tabela Disp para encontrar informacoes de disp_id e client_id--

SELECT
count(*)
FROM disposition

CREATE TEMPORARY TABLE best_clients_loan_all_info AS 
SELECT
client_id, disp_id, best_clients_loan.account_id, status, type, AMOUNT
FROM best_clients_loan
LEFT JOIN disposition on disposition.account_id=best_clients_loan.account_id
WHERE type = "owner"
ORDER BY account_id

DROP TEMPORARY TABLE best_clients_loan_all_info

SELECT
*
FROM best_clients_loan_all_info

-- Relacionando Temp best_clients_loan_all_info com Tabela Credit Card --

SELECT
count(*)
FROM creditcard

SELECT
count(*)
FROM creditcard
RIGHT JOIN best_clients_loan_all_info on creditcard.disp_id=best_clients_loan_all_info.disp_id
WHERE creditcard.type is null;

-- Foi concluído que dos 203 clientes que sao considerados melhores clientes do ponto de vista de emprestimo ja que tiveram seus contratos finalizados sem problemas, 143 ainda nao tem cartao de credito, que poderia ser um serviço a oferta-lo --

-- Definindo os piores clientes do ponto de vista das informações de empréstimos, ou seja, aqueles que concluiram o contrato com emprestimos nao pago--

CREATE TEMPORARY TABLE worts_clients_loan AS
SELECT
	status, account_id, sum(amount) AS AMOUNT
	FROM loan
    WHERE status = "B" or status = "D"    -- WHERE status in ('B','D') --
    GROUP BY account_id, status
	ORDER BY sum(amount) DESC;

DROP TEMPORARY TABLE worts_clients_loan

SELECT
count(account_id)
FROM worts_clients_loan

-- Relacionando Temp piores_clients_loan com Tabela Disp para encontrar informacoes de disp_id e client_id--

SELECT
count(*)
FROM disposition

CREATE TEMPORARY TABLE worts_clients_loan_all_info AS 
SELECT
client_id, disp_id, worts_clients_loan.account_id, status, type, AMOUNT
FROM worts_clients_loan
LEFT JOIN disposition on disposition.account_id = worts_clients_loan.account_id
WHERE type = "owner"
ORDER BY account_id

DROP TEMPORARY TABLE worts_clients_loan_all_info

SELECT
*
FROM worts_clients_loan_all_info
