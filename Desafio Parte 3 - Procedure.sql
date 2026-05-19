CREATE DEFINER=`bazooka`@`192.168.1.%` PROCEDURE `sp_pedidos_clientes`(
    IN p_tx_situacao VARCHAR(30),
    IN p_vl_minimo DECIMAL(12,3),
    IN p_agrupa_cliente BOOLEAN
)
BEGIN
    -- CTE para filtrar e ordenar os pedidos de forma isolada e performática
	IF NOT p_agrupa_cliente OR p_agrupa_cliente IS NULL THEN
		WITH PedidosFiltrados AS (
			SELECT 
				CONCAT(p.id_pedido, CASE WHEN p_tx_situacao = '*' OR p_tx_situacao IS NULL 
										THEN CONCAT(' (', s.tx_situacao_pedido, ')') ELSE '' END) id_pedido,
				p.id_cliente,
				p.dt_pedido,
				p.vl_total
			FROM tb_pedido p
			INNER JOIN tb_situacao_pedido s 
				ON p.id_situacao_pedido = s.id_situacao
			WHERE s.tx_situacao_pedido = CASE WHEN p_tx_situacao = '*' OR p_tx_situacao IS NULL 
											THEN s.tx_situacao_pedido ELSE p_tx_situacao END
			  AND p.vl_total > p_vl_minimo
		)
		-- Consulta final que faz o Join apenas com os clientes dos pedidos já filtrados
		SELECT 
			c.nm_cliente,
			pf.id_pedido,
			pf.dt_pedido,
			FORMAT(ROUND(pf.vl_total, 2), 2,  'pt_BR') vl_total
		FROM PedidosFiltrados pf
		INNER JOIN tb_cliente c 
			ON pf.id_cliente = c.id_cliente
		ORDER BY pf.dt_pedido DESC;
	ELSE
		WITH PedidosFiltrados AS (
			SELECT 
				p.id_cliente,
                MAX(p.dt_pedido) dt_ult_pedido,
				SUM(p.vl_total) vl_total
			FROM tb_pedido p
			INNER JOIN tb_situacao_pedido s 
				ON p.id_situacao_pedido = s.id_situacao
			WHERE s.tx_situacao_pedido = CASE WHEN p_tx_situacao = '*' OR p_tx_situacao IS NULL 
											THEN s.tx_situacao_pedido ELSE p_tx_situacao END
			  AND p.vl_total > p_vl_minimo
			GROUP BY p.id_cliente
		)
		-- Consulta final que faz o Join apenas com os clientes dos pedidos já filtrados
		SELECT 
			c.nm_cliente,
			pf.dt_ult_pedido,
			FORMAT(ROUND(pf.vl_total, 2), 2,  'pt_BR') vl_total_pedidos
		FROM PedidosFiltrados pf
		INNER JOIN tb_cliente c 
			ON pf.id_cliente = c.id_cliente
		ORDER BY c.nm_cliente, c.cd_cpf;
    END IF;
END