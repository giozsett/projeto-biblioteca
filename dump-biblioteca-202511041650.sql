-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: localhost    Database: biblioteca
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `emprestimos`
--

DROP TABLE IF EXISTS `emprestimos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emprestimos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `data_emprestimo` date NOT NULL,
  `data_devolucao` date DEFAULT NULL,
  `emprestimo_ativo` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'S',
  `id_usuario` int NOT NULL,
  `id_livro` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `emprestimos_usuarios_FK` (`id_usuario`),
  KEY `emprestimos_livros_FK` (`id_livro`),
  CONSTRAINT `emprestimos_livros_FK` FOREIGN KEY (`id_livro`) REFERENCES `livros` (`id`),
  CONSTRAINT `emprestimos_usuarios_FK` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emprestimos`
--

LOCK TABLES `emprestimos` WRITE;
/*!40000 ALTER TABLE `emprestimos` DISABLE KEYS */;
INSERT INTO `emprestimos` VALUES (1,'2025-10-20','2025-10-30','S',1,1),(2,'2025-10-30','2025-11-03','S',1,4),(3,'2025-10-20','2025-10-30','N',1,6);
/*!40000 ALTER TABLE `emprestimos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_emprestimosBI` BEFORE INSERT ON `emprestimos` FOR EACH ROW begin
	DECLARE v_usuario_ativo CHAR(1);
    DECLARE v_livro_ativo CHAR(1);
    DECLARE v_qtd_disponivel INT;
	
	/*verifica se o usuário existe*/
	SELECT usuario_ativo
    INTO v_usuario_ativo
    FROM usuarios
    WHERE id = NEW.id_usuario;
    IF v_usuario_ativo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário informado não encontrado.';
    END IF;
    
    /*verifica se o usuário está ativo/não foi deletado*/
        IF v_usuario_ativo = 'N' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário informado está inativo.';
    END IF;
    
    /*verifica se o livro existe*/
        SELECT livro_ativo, quant_disponivel
    INTO v_livro_ativo, v_qtd_disponivel
    FROM livros
    WHERE id = NEW.id_livro;
    IF v_livro_ativo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livro informado não existe.';
    END IF;
    
    /*verifica se o livro está ativo/não foi deletado*/
        IF v_livro_ativo = 'N' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livro informado está inativo.';
    END IF;
    
    /*verifica se o livro está disponível, pois não é possível emprestar livro com quantidade disponível = 0*/
        IF v_qtd_disponivel = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livro sem exemplares disponíveis.';
    END IF;
    
    /* verifica se a data de devolução não é anterior à data de empréstimo */
    IF NEW.data_devolucao < NEW.data_emprestimo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de devolução não pode ser anterior à data de empréstimo.';
    END IF;

    /*verifica se a data de empréstimo não é no futuro */
    IF NEW.data_emprestimo > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de empréstimo não pode ser uma data futura.';
    END IF;
    
    /*verifica se a data de devolução não é no futuro */
    IF NEW.data_devolucao > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de devolução não pode ser uma data futura.';
    END IF;
   end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_emprestimosAI` AFTER INSERT ON `emprestimos` FOR EACH ROW begin
    INSERT INTO log_geral (
        nome_tabela,
        id_tabela,
        acao,
        nome_responsavel
    )
    VALUES ('emprestimos', NEW.id, 'INSERT', USER());

end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_emprestimosBU` BEFORE UPDATE ON `emprestimos` FOR EACH ROW BEGIN
		DECLARE v_usuario_ativo CHAR(1);
    DECLARE v_livro_ativo CHAR(1);
    DECLARE v_qtd_disponivel INT;
	
	/*verifica se o usuário existe*/
	SELECT usuario_ativo
    INTO v_usuario_ativo
    FROM usuarios
    WHERE id = NEW.id_usuario;
    IF v_usuario_ativo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário informado não encontrado.';
    END IF;
    
    /*verifica se o usuário está ativo/não foi deletado*/
        IF v_usuario_ativo = 'N' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário informado está inativo.';
    END IF;
    
    /*verifica se o livro existe*/
        SELECT livro_ativo, quant_disponivel
    INTO v_livro_ativo, v_qtd_disponivel
    FROM livros
    WHERE id = NEW.id_livro;
    IF v_livro_ativo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livro informado não existe.';
    END IF;
    
    /*verifica se o livro está ativo/não foi deletado*/
        IF v_livro_ativo = 'N' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livro informado está inativo.';
    END IF;
    
    /*verifica se o livro está disponível, pois não é possível emprestar livro com quantidade disponível = 0*/
        IF v_qtd_disponivel = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Livro sem exemplares disponíveis.';
    END IF;
    
    /* verifica se a data de devolução não é anterior à data de empréstimo */
    IF NEW.data_devolucao < NEW.data_emprestimo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de devolução não pode ser anterior à data de empréstimo.';
    END IF;

    /*verifica se a data de empréstimo não é no futuro */
    IF NEW.data_emprestimo > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de empréstimo não pode ser uma data futura.';
    END IF;
    
    /*verifica se a data de devolução não é no futuro */
    IF NEW.data_devolucao > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de devolução não pode ser uma data futura.';
    END IF;
   end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_emprestimosAU` AFTER UPDATE ON `emprestimos` FOR EACH ROW begin
	    /*alteração na data de empréstimo */
    IF (NEW.data_emprestimo <> OLD.data_emprestimo) THEN
        INSERT INTO log_geral (nome_tabela,
                               id_tabela,
                               campo_modificado,
                               acao,
                               valor_antigo,
                               valor_novo,
                               nome_responsavel)
        VALUES ('emprestimos', NEW.id, 'data_emprestimo', 'UPDATE',
                OLD.data_emprestimo, NEW.data_emprestimo, USER());
    END IF;

    /*alteração na data de devolução */
    IF (NEW.data_devolucao <> OLD.data_devolucao) THEN
        INSERT INTO log_geral (nome_tabela,
                               id_tabela,
                               campo_modificado,
                               acao,
                               valor_antigo,
                               valor_novo,
                               nome_responsavel)
        VALUES ('emprestimos', NEW.id, 'data_devolucao', 'UPDATE',
                OLD.data_devolucao, NEW.data_devolucao, USER());
    END IF;

    /*alteração no status de ativo/inativo (soft delete) */
    IF (NEW.emprestimo_ativo <> OLD.emprestimo_ativo) THEN
        INSERT INTO log_geral (nome_tabela,
                               id_tabela,
                               campo_modificado,
                               acao,
                               valor_antigo,
                               valor_novo,
                               nome_responsavel)
        VALUES ('emprestimos', NEW.id, 'emprestimo_ativo', 'DELETE',
                OLD.emprestimo_ativo, NEW.emprestimo_ativo, USER());
    END IF;

    /* alteração no usuário vinculado ao empréstimo */
    IF (NEW.id_usuario <> OLD.id_usuario) THEN
        INSERT INTO log_geral (nome_tabela,
                               id_tabela,
                               campo_modificado,
                               acao,
                               valor_antigo,
                               valor_novo,
                               nome_responsavel)
        VALUES ('emprestimos', NEW.id, 'id_usuario', 'UPDATE',
                OLD.id_usuario, NEW.id_usuario, USER());
    END IF;

    /* alteração no livro vinculado ao empréstimo */
    IF (NEW.id_livro <> OLD.id_livro) THEN
        INSERT INTO log_geral (nome_tabela,
                               id_tabela,
                               campo_modificado,
                               acao,
                               valor_antigo,
                               valor_novo,
                               nome_responsavel)
        VALUES ('emprestimos', NEW.id, 'id_livro', 'UPDATE',
                OLD.id_livro, NEW.id_livro, USER());
    END IF;
 end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_emprestimosBD` BEFORE DELETE ON `emprestimos` FOR EACH ROW BEGIN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Exclusão física não permitida. Use soft delete alterando status para Inativo.';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `livros`
--

DROP TABLE IF EXISTS `livros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livros` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(100) NOT NULL,
  `autor` varchar(100) NOT NULL,
  `quantidade` int NOT NULL,
  `quant_disponivel` int NOT NULL,
  `categoria` varchar(100) NOT NULL,
  `livro_ativo` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'S',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES (1,'livro teste 1','fulano de tal',1,1,'romance','N'),(2,'livro teste 2','fulano de tal',1,0,'romance','N'),(3,'livro teste 3','fulano de tal',1,1,'romance','N'),(4,'Dom Casmurro','Machado de Assis',3,2,'Literatura Brasileira','N'),(6,'It, a Coisa','Stephen King',2,2,'Terror','S'),(7,'A Menina que Roubava Livros','Markus Zusak',10,10,'Romance','S');
/*!40000 ALTER TABLE `livros` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_livrosBI` BEFORE INSERT ON `livros` FOR EACH ROW BEGIN
    /*impede valores negativos em quantidade*/
    IF NEW.quantidade < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade do livro não pode ser negativa.';
    END IF;

    /*impede valores negativos em quant_disponivel*/
    IF NEW.quant_disponivel < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade disponível não pode ser negativa.';
    END IF;

    /*impede que quant_disponivel seja maior que a quantidade total*/
    IF NEW.quant_disponivel > NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade disponível não pode ser maior que a quantidade total.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_livrosAI` AFTER INSERT ON `livros` FOR EACH ROW BEGIN
    INSERT INTO log_geral (
        nome_tabela,
        id_tabela,
        acao,
        nome_responsavel
    )
    VALUES ('livros', NEW.id, 'INSERT', USER());

end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_livrosBU` BEFORE UPDATE ON `livros` FOR EACH ROW BEGIN
    /*impede valores negativos em quantidade*/
    IF NEW.quantidade < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade do livro não pode ser negativa.';
    END IF;

    /*impede valores negativos em 'quant_disponivel'*/
    IF NEW.quant_disponivel < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade disponível não pode ser negativa.';
    END IF;

    /*impede que quant_disponivel seja maior que a quantidade total*/
    IF NEW.quant_disponivel > NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade disponível não pode ser maior que a quantidade total.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_livrosAU` AFTER UPDATE ON `livros` FOR EACH ROW /*adiciona os logs dos udates feitos na tabela livros à tabela log_geral*/
	/*alteração do título do livro*/
	BEGIN
		 IF (new.titulo <> old.titulo) THEN
		INSERT INTO log_geral (nome_tabela,
							   id_tabela,
                               campo_modificado,
							   acao,
							   valor_antigo,
							   valor_novo,
							   nome_responsavel)
			VALUES ('livros', new.id,'titulo','UPDATE',
					old.titulo, new.titulo, user());
 			END IF;
	
			/*alterações no nome do autor*/
			 IF (new.autor <> old.autor) THEN
		INSERT INTO log_geral (nome_tabela,
							   id_tabela,
                               campo_modificado,
							   acao,
							   valor_antigo,
							   valor_novo,
							   nome_responsavel)
			VALUES ('livros', new.id,'autor','UPDATE',
					old.autor, new.autor, user());
 			END IF;
			
			/*alterações na quantidade*/
					 IF (new.quantidade <> old.quantidade) THEN
		INSERT INTO log_geral (nome_tabela,
							   id_tabela,
                               campo_modificado,
							   acao,
							   valor_antigo,
							   valor_novo,
							   nome_responsavel)
			VALUES ('livros', new.id,'quantidade','UPDATE',
					old.quantidade, new.quantidade, user());
			 END IF;
			
		/*alterações na categoria do livro*/
					 IF (new.categoria <> old.categoria) THEN
		INSERT INTO log_geral (nome_tabela,
							   id_tabela,
                               campo_modificado,
							   acao,
							   valor_antigo,
							   valor_novo,
							   nome_responsavel)
			VALUES ('livros', new.id,'categoria','UPDATE',
					old.categoria, new.categoria, user());
		 END IF;
		
		/*registrando a mudança de livro_ativo='S' para livro_ativo='N' como DELETE.*/
		 IF (new.livro_ativo <> old.livro_ativo) THEN
		INSERT INTO log_geral (nome_tabela,
							   id_tabela,
                               campo_modificado,
							   acao,
							   valor_antigo,
							   valor_novo,
							   nome_responsavel)
			VALUES ('livros', new.id,'livro_ativo','DELETE',
					old.livro_ativo, new.livro_ativo, user());
		 END IF;

end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_livrosBD` BEFORE DELETE ON `livros` FOR EACH ROW BEGIN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Exclusão física não permitida. Use soft delete alterando status para ativo = N.';
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `log_geral`
--

DROP TABLE IF EXISTS `log_geral`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_geral` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_tabela` int NOT NULL,
  `nome_tabela` varchar(15) NOT NULL,
  `acao` varchar(10) NOT NULL,
  `valor_antigo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `valor_novo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `data_modificacao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nome_responsavel` varchar(100) NOT NULL,
  `campo_modificado` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_geral`
--

LOCK TABLES `log_geral` WRITE;
/*!40000 ALTER TABLE `log_geral` DISABLE KEYS */;
INSERT INTO `log_geral` VALUES (1,1,'livros','DELETE','S','N','2025-11-03 18:28:28','root@localhost','livro_ativo'),(2,2,'livros','DELETE','S','N','2025-11-03 18:37:21','root@localhost','livro_ativo'),(3,4,'livros','UPDATE','2','3','2025-11-03 19:36:33','root@localhost','quantidade'),(4,6,'livros','INSERT',NULL,NULL,'2025-11-04 18:16:14','root@localhost',NULL),(5,4,'livros','DELETE','S','N','2025-11-04 18:22:46','root@localhost','livro_ativo'),(6,3,'emprestimos','DELETE','S','N','2025-11-04 18:42:24','root@localhost','emprestimo_ativo'),(7,7,'livros','INSERT',NULL,NULL,'2025-11-04 19:46:59','root@localhost',NULL),(8,7,'livros','INSERT',NULL,NULL,'2025-11-04 19:46:59','giovana',NULL);
/*!40000 ALTER TABLE `log_geral` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(100) NOT NULL,
  `bloqueado` char(1) NOT NULL DEFAULT 'N',
  `tentativas` int NOT NULL DEFAULT '0',
  `usuario_ativo` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'S',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'fulano da silva','fulano@a','fulano123','N',0,'S'),(2,'fulano teste','fteste@a','fteste','N',0,'N');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tg_usuariosBD` BEFORE DELETE ON `usuarios` FOR EACH ROW begin
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Exclusão física não permitida. Use soft delete alterando status para Inativo.';
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'biblioteca'
--
/*!50003 DROP PROCEDURE IF EXISTS `pr_cadastra_livro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_cadastra_livro`(
    IN p_titulo VARCHAR(100),
    IN p_autor VARCHAR(100),
    IN p_quantidade INT,
    IN p_quant_disponivel INT,
    IN p_categoria VARCHAR(100),
    IN p_usuario VARCHAR(100),
    OUT p_status ENUM('Erro', 'Sucesso')
)
BEGIN
    START TRANSACTION;

    /*inserindo os dados do novo livro*/
    INSERT INTO livros (
        titulo,
        autor,
        quantidade,
        quant_disponivel,
        categoria,
        livro_ativo
    ) VALUES (
        p_titulo,
        p_autor,
        p_quantidade,
        p_quant_disponivel,
        p_categoria,
        'S'
    );

    /*Armazena o ID gerado automaticamente*/
    SET @livro_id = LAST_INSERT_ID();

    /*insere o registro na tabela de log_geral*/
    INSERT INTO log_geral (
        nome_tabela,
        id_tabela,
        acao,
        nome_responsavel,
        valor_antigo,
        valor_novo,
        campo_modificado
    )
    VALUES (
        'livros',
        @livro_id,
        'INSERT',
        p_usuario,
        NULL,
        NULL,
        NULL
    );

    COMMIT;
    SET p_status = 'Sucesso';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `pr_soft_delete_emprestimo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_soft_delete_emprestimo`(
	IN p_id_emprestimo INT,
	IN p_usuario VARCHAR(100),
	OUT p_status enum('Erro', 'Sucesso')
)
BEGIN
    DECLARE v_emprestimo_ativo CHAR(1);

    SET p_status = 'ERRO';

    SELECT emprestimo_ativo
    INTO v_emprestimo_ativo
    FROM emprestimos
    WHERE id = p_id_emprestimo LIMIT 1;

    IF v_emprestimo_ativo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empréstimo não encontrado';
    END IF;

    IF v_emprestimo_ativo = 'N' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empréstimo já está inativo';
    ELSE
        UPDATE emprestimos
        SET emprestimo_ativo = 'N'
        WHERE id = p_id_emprestimo;

        INSERT INTO log_geral (nome_tabela,
            id_tabela,
            campo_modificado,
            acao,
            valor_antigo,
            valor_novo,
            nome_responsavel,
            data_modificacao
        )
        VALUES ('emprestimos', p_id_emprestimo, 'emprestimo_ativo', 'DELETE', v_emprestimo_ativo, 'N', p_usuario);

        SET p_status = 'Sucesso';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `pr_soft_delete_livro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_soft_delete_livro`(
	IN p_id_livro INT,
	IN p_usuario VARCHAR(100),
    OUT p_status ENUM('Erro','Sucesso')
	)
BEGIN
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_livro_ativo CHAR(1);

    SET p_status = 'Erro';

    SELECT titulo, livro_ativo
    INTO v_titulo, v_livro_ativo
    FROM livros
    WHERE id = p_id_livro
    LIMIT 1;

    IF v_titulo IS NULL OR v_livro_ativo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Livro não encontrado';
    END IF;

    IF v_livro_ativo = 'N' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Livro já está inativo';
    ELSE
        UPDATE livros
        SET livro_ativo = 'N'
        WHERE id = p_id_livro;

        INSERT INTO log_geral (nome_tabela,
            id_tabela,
            campo_modificado,
            acao,
            valor_antigo,
            valor_novo,
            nome_responsavel,
            data_modificacao
        )
        VALUES ('livros', p_id_livro, 'livro_ativo', 'DELETE', v_livro_ativo, 'N', p_usuario);

        SET p_status = 'Sucesso';
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

-- Dump completed on 2025-11-04 16:50:44
