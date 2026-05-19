CREATE DEFINER=`bazooka`@`192.168.1.%` PROCEDURE `sp_relatorio_vendas_periodo`(
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    IN p_categoria_produto VARCHAR(100)
)
BEGIN
	-- Calcula o total de pedidos, soma vendida e média por pedido para a categoria
	SELECT 
		COUNT(DISTINCT p.ID_PEDIDO) AS total_pedidos,
		FORMAT(ROUND(SUM(ip.QT_PRODUTO * ip.VL_UNITARIO), 2), 2, 'pt_BR') AS soma_valor_total, 
		FORMAT(ROUND(IFNULL(SUM(ip.QT_PRODUTO * ip.VL_UNITARIO) / COUNT(DISTINCT p.ID_PEDIDO), 0.000), 2), 2, 'pt_BR') 
			AS media_por_pedido
	FROM TB_PEDIDO p
	JOIN TB_ITEM_PEDIDO ip ON p.ID_PEDIDO = ip.ID_PEDIDO
	JOIN TB_PRODUTO prod ON ip.ID_PRODUTO = prod.ID_PRODUTO
	JOIN TB_CATEGORIA_PRODUTO cat ON prod.ID_CATEGORIA_PRODUTO = cat.ID_CATEGORIA_PRODUTO
	WHERE p.DT_PEDIDO >= p_data_inicio 
	  AND p.DT_PEDIDO <= p_data_fim
	  AND cat.NM_CATEGORIA_PRODUTO = 
		CASE WHEN p_categoria_produto IS NULL OR p_categoria_produto = '*' THEN cat.NM_CATEGORIA_PRODUTO ELSE p_categoria_produto END;

	-- Lista os produtos daquela categoria e a quantidade total vendida deles
	SELECT 
		CONCAT(prod.NM_PRODUTO, 
			CASE WHEN p_categoria_produto IS NULL OR p_categoria_produto = '*' THEN '(' ELSE '' END,
			CASE WHEN p_categoria_produto IS NULL OR p_categoria_produto = '*' 
				THEN cat.NM_CATEGORIA_PRODUTO ELSE '' END,
			CASE WHEN p_categoria_produto IS NULL OR p_categoria_produto = '*' THEN ')' ELSE '' END
		) AS nome_produto,
		SUM(ip.QT_PRODUTO) AS quantidade_vendida
	FROM TB_PEDIDO p
	JOIN TB_ITEM_PEDIDO ip ON p.ID_PEDIDO = ip.ID_PEDIDO
	JOIN TB_PRODUTO prod ON ip.ID_PRODUTO = prod.ID_PRODUTO
	JOIN TB_CATEGORIA_PRODUTO cat ON prod.ID_CATEGORIA_PRODUTO = cat.ID_CATEGORIA_PRODUTO
    -- Aqui usando método alternativo para filtro de datas
	WHERE p.DT_PEDIDO BETWEEN p_data_inicio AND p_data_fim
	  AND cat.NM_CATEGORIA_PRODUTO = 
		CASE WHEN p_categoria_produto IS NULL OR p_categoria_produto = '*' THEN cat.NM_CATEGORIA_PRODUTO ELSE p_categoria_produto END
	GROUP BY prod.ID_PRODUTO, prod.NM_PRODUTO;
END