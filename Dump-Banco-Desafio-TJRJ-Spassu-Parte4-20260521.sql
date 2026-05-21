-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 192.168.1.34    Database: db_lab
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `flyway_schema_history`
--

DROP TABLE IF EXISTS `flyway_schema_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flyway_schema_history` (
  `installed_rank` int NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `flyway_schema_history_s_idx` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flyway_schema_history`
--

LOCK TABLES `flyway_schema_history` WRITE;
/*!40000 ALTER TABLE `flyway_schema_history` DISABLE KEYS */;
INSERT INTO `flyway_schema_history` VALUES (1,'1','create recurso acao processo','SQL','V1__create_recurso_acao_processo.sql',2014433173,'bazooka','2026-05-21 14:03:05',78,1),(2,'2','ajuste coluna data','SQL','V2__ajuste_coluna_data.sql',1435577927,'bazooka','2026-05-21 14:03:05',203,1),(3,'4','upsert sp','SQL','V4__upsert_sp.sql',-1065465043,'bazooka','2026-05-21 14:34:41',64,1);
/*!40000 ALTER TABLE `flyway_schema_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurso_acao_processo`
--

DROP TABLE IF EXISTS `recurso_acao_processo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurso_acao_processo` (
  `id_recurso_acao_processo` int NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `ativo` int DEFAULT NULL,
  `data_inclusao` datetime(6) DEFAULT NULL,
  `id_usuario_inclusao` int DEFAULT NULL,
  PRIMARY KEY (`id_recurso_acao_processo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurso_acao_processo`
--

LOCK TABLES `recurso_acao_processo` WRITE;
/*!40000 ALTER TABLE `recurso_acao_processo` DISABLE KEYS */;
INSERT INTO `recurso_acao_processo` VALUES (532,'Vincular boleto',1,'2026-05-21 14:04:05.000000',53);
/*!40000 ALTER TABLE `recurso_acao_processo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_usuario`
--

DROP TABLE IF EXISTS `tb_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_usuario` (
  `ID_USUARIO` int NOT NULL,
  `NM_LOGIN` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID_USUARIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_usuario`
--

LOCK TABLES `tb_usuario` WRITE;
/*!40000 ALTER TABLE `tb_usuario` DISABLE KEYS */;
INSERT INTO `tb_usuario` VALUES (53,'Marcelo');
/*!40000 ALTER TABLE `tb_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'db_lab'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_recurso_acao_processo_upsert` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`bazooka`@`%` PROCEDURE `sp_recurso_acao_processo_upsert`(
    IN p_id_recurso INT,
    IN p_nome VARCHAR(255),
    IN p_ativo TINYINT,
    IN p_login_usuario VARCHAR(100),
    IN p_atualiza_dados BOOLEAN,
    OUT p_status_codigo INT,      -- 1: Inserido, 2: Atualizado, 0: Sem alterações, -1: Erro
    OUT p_status_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_linhas_afetadas INT;

    -- Tratamento de erros/exceções do MySQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 p_status_mensagem = MESSAGE_TEXT;
        SET p_status_codigo = -1;
        ROLLBACK;
    END;

    START TRANSACTION;

    -- 1. Busca dinâmica do ID do usuário pelo login numa hipotética tabela de usuários (independência de ambiente)
    SELECT id_usuario INTO v_id_usuario 
    FROM tb_usuario 
    WHERE nm_login = p_login_usuario 
    LIMIT 1;

    -- Validação de consistência do usuário
    IF v_id_usuario IS NULL THEN
        SET p_status_codigo = -1;
        SET p_status_mensagem = CONCAT('Erro: Usuário "', p_login_usuario, '" não cadastrado neste ambiente.');
        ROLLBACK;
    ELSE
        -- 2. O Conceito de UPSERT nativo do MySQL
        INSERT INTO recurso_acao_processo (
            id_recurso_acao_processo,
            nome,
            ativo,
            data_inclusao,
            id_usuario_inclusao
        ) VALUES (
            p_id_recurso,
            p_nome,
            p_ativo,
            NOW(),
            v_id_usuario
        )
        ON DUPLICATE KEY UPDATE
            -- Se o ID já existir, o MySQL executa o bloco abaixo (condicionalmente, de acordo com a necessidade):
            nome = IF(p_atualiza_dados, VALUES(nome), nome),
            ativo = IF(p_atualiza_dados, VALUES(ativo), ativo),
            data_inclusao = IF(p_atualiza_dados, VALUES(data_inclusao), data_inclusao),
            id_usuario_inclusao = IF(p_atualiza_dados, VALUES(id_usuario_inclusao), id_usuario_inclusao);

        -- 3. Captura do Status real através do ROW_COUNT() do motor do MySQL
        SET v_linhas_afetadas = ROW_COUNT();

        -- No MySQL, o ROW_COUNT() para ON DUPLICATE KEY retorna:
        -- 1 se a linha foi inserida nova.
        -- 2 se uma linha existente foi atualizada com novos valores.
        -- 0 se a linha já existia mas os dados passados eram exatamente iguais aos atuais.

		SET p_status_codigo = v_linhas_afetadas;

		CASE p_status_codigo
			WHEN 1 THEN
				SET p_status_mensagem = 'Sucesso: Registro inserido com êxito.';
            WHEN 2 THEN
				SET p_status_mensagem = 'Sucesso: Registro já existia e foi atualizado (Upsert).';
            WHEN 0 THEN
				SET p_status_mensagem = 'Ignorado: Registro já existia com os mesmos dados. Nenhuma alteração necessária.';
		END CASE;

        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-21 16:36:29
