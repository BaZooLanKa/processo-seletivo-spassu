USE db_supermercado;

-- Desafio original
SELECT c.nome, p.id, p.valor_total
FROM pedidos p, clientes c
WHERE p.id_cliente = c.id
AND p.status = 'concluido'
AND p.valor_total > 1000
ORDER BY p.data_criacao DESC;

-- Desafio transcrito para o padrão modelado do banco
SELECT c.nm_cliente, p.id_pedido, p.vl_total
FROM tb_pedido p, tb_cliente c
WHERE p.id_cliente = c.id_cliente
AND p.id_situacao_pedido = 3 -- 'Concluído'
AND p.vl_total > 1000 
ORDER BY p.dt_pedido DESC;

-- Problemas encontrados:
# Junção clássica implícita (Oracle), visualmente difícil de identificar - preferível utilizar junções explícitas (ANSI-92)
# Busca em campo textual degrada performance - é preciso criar um índice, se o contexto textual for controlado
#	Nesse caso, é preciso fazer outra junção, para permitir a consulta textual, pois na normalização criou-se uma tabela de domínio
# Busca de valores por escopo degrada performance - é preciso criar um índice, pra evitar full scan na tabela
# Ordenação degrada performance - os campos da ordenação precisam fazer parte de um índice
# Consulta única com vários filtros fica difícil de ler - montagem com CTE fica visualmente mais lógica e pode melhorar performance
# A coluna de data do pedido, embora esteja sendo usada na ordenação, não aparece no resultado. Seria conveniente mostrá-la;
