
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

CREATE TEMPORARY TABLE worst_clients_loan AS
SELECT
	status, account_id, sum(amount) AS AMOUNT
	FROM loan
    WHERE status = "B" or status = "D"    -- WHERE status in ('B','D') --
    GROUP BY account_id, status
	ORDER BY sum(amount) DESC;

DROP TEMPORARY TABLE worst_clients_loan

SELECT
count(account_id)
FROM worts_clients_loan

-- Relacionando Temp piores_clients_loan com Tabela Disp para encontrar informacoes de disp_id e client_id--

SELECT
count(*)
FROM disposition

CREATE TEMPORARY TABLE worst_clients_loan_all_info AS 
SELECT
client_id, disp_id, worst_clients_loan.account_id, status, type, AMOUNT
FROM worst_clients_loan
LEFT JOIN disposition on disposition.account_id = worst_clients_loan.account_id
WHERE type = "owner"
ORDER BY account_id

DROP TEMPORARY TABLE worst_clients_loan_all_info

SELECT
*
FROM worst_clients_loan_all_info

-- Relacionando Temp worts_clients_loan_all_info com Tabela Credit Card --

SELECT
count(*)
FROM creditcard

SELECT
*
FROM creditcard
RIGHT JOIN worst_clients_loan_all_info on creditcard.disp_id=worst_clients_loan_all_info.disp_id
WHERE creditcard.type is not null;

-- Foi concluído que 5 clientes que sao classificados como piores clientes do ponto de vista de emprestimo, possuem cartao. Para estes clientes o cartao deveria ser cancelado ou suspenso ate a quitação da divida de emprestimo.

-- Criando uma tabela com as ulimas transacoes dos clientes--

CREATE TEMPORARY TABLE last_transaction AS 
SELECT
account_id, max(date) AS last_transaction
FROM transactions
GROUP BY account_id
ORDER BY account_id

DROP TEMPORARY TABLE last_transaction

-- Criando uma tabela com as últimas transacoes dos clientes--

CREATE TEMPORARY TABLE last_transactions_clients
SELECT
last_transaction.*,trans_id, balance
FROM transactions
INNER JOIN last_transaction ON transactions.account_id = last_transaction.account_id AND transactions.date = last_transaction.last_transaction

DROP TEMPORARY TABLE last_transactions_clients

-- Relacionando a tabela de ultimas transacoes dos clientes com a tabela dos piores clientes --

SELECT
client_id, disp_id, trans_id, worst_clients_loan_all_info.account_id, last_transaction, status, type, AMOUNT, balance
FROM worst_clients_loan_all_info 
INNER JOIN last_transactions_clients ON worst_clients_loan_all_info.account_id = last_transactions_clients.account_id
ORDER BY balance

-- Descobrindo valores pagos por emprestimo --

CREATE TEMPORARY TABLE AS loan_payment
SELECT 
worst_clients_loan_all_info.*, K_symbol, permanentorder.amount AS debited_amount
FROM permanentorder
INNER JOIN worst_clients_loan_all_info ON worst_clients_loan_all_info.account_id = permanentorder.account_id
WHERE K_symbol = "UVER"

DROP TEMPORARY TABLE loan_payment

SELECT 
*
FROM loan_payment
