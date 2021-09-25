    CREATE DATABASE Cafeteria;
    GO
    USE Cafeteria;
    GO


	 /* Vamos criar uma tabela para clientes */
    CREATE TABLE CLIENTES(
		ID_CLIENTE_CPF INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        NOME VARCHAR(50) NOT NULL,
		ENDERECO VARCHAR(100) NOT NULL,
		TELEFONE INT NOT NULL,
    );

	/* Vamos criar uma tabela para pedidos dos clientes*/
	CREATE TABLE PEDIDOS(
	ID_PEDIDO INT PRIMARY KEY NOT NULL,
	PEDIDO_VALOR_TOTAL DECIMAL (5,2)
	);

	/* Vamos relacionar pedidos a clientes */
	ALTER TABLE PEDIDOS 
	ADD PEDIDO_CLIENTEFK INT;
	ALTER TABLE PEDIDOS ADD CONSTRAINT CLIENTEFK FOREIGN KEY (PEDIDO_CLIENTEFK) REFERENCES CLIENTES (ID_CLIENTE_CPF);
	
	/* Vamos criar uma tabela de itens do pedidos*/
	CREATE TABLE ITEMPEDIDOS(
		ID_ITEM INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		QUANTIDADE_ITEM_PRODUTO INT,
		PRODUTOFK_ITEM INT,
		PEDIDOFK_ITEM INT,
	);

	/* Vamos criar uma tabela de insumos para depois fazer um update,
	esses insumos serão utilizados na hora de fazer um produto*/
	CREATE TABLE INSUMOS(
		ID_INSUMO INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		INSUMO_NOME VARCHAR(20),
		INSUMO_QUANTIDADE INT,
		INSUMO_UNIDADEMEDIDA VARCHAR(3),
		INSUMO_PRECOUNIT DECIMAL (5,2));


	/* Vamos colocar alguns insumos de exemplo, tem dezenas
	porem colocamos apenas alguns*/
	INSERT INTO INSUMOS VALUES
	('Leite', 120 , 'L', 2.36), ('Açucar', 30000 , 'G', 0.0359),
	('Café Especial Grão', 12000 , 'G', 0.059), ('Canela em pó', 300 , 'G', 0.10);

	/* Vamos criar uma tabela para os produtos que os clientes vão comprar 
	nesse caso será cafés*/
	CREATE TABLE PRODUTOS(
		ID_PRODUTO INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		PRODUTO_NOME VARCHAR(30),
		PRODUTO_TAMANHO VARCHAR(30),
		PRODUTO_PRECOUNIT DECIMAL(5,2),
		PRODUTO_QUANTIDADETOTAL INT
	);
             
	/* Inserimos os produtos / cafés  */
	INSERT INTO PRODUTOS VALUES
	('CAFÉ MOCCHA','MÉDIO', 12.50 , 0),
	('CAFÉ EXPRESSO','PEQUENO', 6 , 0), ( 'CAFÉ AMERICANO','MÉDIO', 7 , 0),
	('CAFÉ CAPPUCCINO','GRANDE', 13.50 , 0), ('CAFÉ DUPLO','MÉDIO', 8 , 0);

	/* Vamos criar uma tabela de itens do café,
	está tabela relaciona os insumos que usamos para fazer cada café*/
	CREATE TABLE ITEMCAFE(
	ID_ITEMCAFE INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ITEM_QUANTIDADEINSUMO Decimal,
	ITEM_INSUMOFK INT,
	ITEM_PRODUTOFK INT, 
	);

	/* Vamos relacionar itens do café em produtos e insumos*/

	ALTER TABLE ITEMCAFE ADD CONSTRAINT ITEMPRODUTOFK FOREIGN KEY (ITEM_PRODUTOFK) REFERENCES PRODUTOS (ID_PRODUTO);
	ALTER TABLE ITEMCAFE ADD CONSTRAINT ITEMINSUMOFK FOREIGN KEY (ITEM_INSUMOFK) REFERENCES INSUMOS (ID_INSUMO);


	/* Vamos inserir quais insumos o café " x " utiliza
	neste exemplo inserimos os insumos do café 1 - Moccha
	Observe que: primeiro valor é a quantidade de insumo
	o segundo valor é qual insumo
	e o terceiro valor é qual café*/


	INSERT INTO ITEMCAFE VALUES(0.2 , 1 ,1), (3,2,1), (20,3,1), (4,4,1);

    /* Vamos criar uma visualização para que possamos
	ver os ingredientes que tem no estoque e suas quantidades.
	Essa visualização é importante, pois ao criar um café 
	iremos diminuir os itens do estoque. */

	CREATE VIEW ESTOQUE AS SELECT INSUMO_NOME as 'Produto', INSUMO_QUANTIDADE as 'Quantidade', INSUMO_UNIDADEMEDIDA as 'UnidadeMedida' FROM INSUMOS;









	/*                             PROCEDURES                            */
	/*              Iniciamos aqui, a parte de procedures               */
	/* Sugerimos que crie uma nova consulta para inserir as procedures */


	/* Vamos criar uma procedure diminuir os insumos, ingredientes
	cada vez que um café é feito e comprado.
	Observe que é possível colocar update para todos os cafés/ produtos 
	que você adicionou, porém para exemplo utilizamos apenas o café 1 - Moccha*/
	CREATE PROCEDURE abaixaInsumo (@CAFE INT)
	AS
		BEGIN
			IF @CAFE = 1
					UPDATE INSUMOS SET INSUMO_QUANTIDADE = INSUMO_QUANTIDADE - 0.2 WHERE ID_INSUMO = 1;
					UPDATE INSUMOS SET INSUMO_QUANTIDADE = INSUMO_QUANTIDADE - 3 WHERE ID_INSUMO = 2;
					UPDATE INSUMOS SET INSUMO_QUANTIDADE = INSUMO_QUANTIDADE - 20 WHERE ID_INSUMO = 3;
					UPDATE INSUMOS SET INSUMO_QUANTIDADE = INSUMO_QUANTIDADE - 5 WHERE ID_INSUMO = 4;
			END;



	/* Vamos criar uma procedure para cadastra um novo cliente */
	CREATE PROCEDURE cadastrarCliente (@CPF INT, @NOME VARCHAR(50), @ENDERECO VARCHAR(100), @TELEFONE INT)
	AS
	BEGIN
				INSERT INTO CLIENTES (ID_CLIENTE_CPF, NOME, ENDERECO, TELEFONE) VALUES (@CPF, @NOME, @ENDERECO, @TELEFONE);
				SELECT 'INFORMA ! O Cliente foi cadastrado com sucesso' AS SUCESSO;
	END;

	/* Vamos criar uma procedure para procurar ou buscar
	um cliente, nessa procedure buscamos o cliente pelo seu id cpf */

	CREATE PROCEDURE procuraCliente(@CPF INT)
	AS
	BEGIN
				SELECT * FROM CLIENTES WHERE ID_CLIENTE_CPF = @CPF;
		END;


	/* Vamos criar uma procedure para anotar os itens de cada pedido
	" Quando um cliente compra ele impoe quais itens ele quer nessa compra " */

	CREATE PROCEDURE anotaItensPedido(@IDPROD INT, @QTDPROD INT, @IDPED INT)
	AS
	BEGIN
		INSERT INTO ITEMPEDIDOS VALUES (@QTDPROD, @IDPROD, @IDPED);
	END;


	/* Vamos criar uma procedure para registra esse pedido,
	verificar qual o seu preço final e alocar de quem foi o pedido 
	por id cpf */

	CREATE PROCEDURE registraPedido(@ID INT, @CPF INT)
	AS
	BEGIN
		DECLARE @VALORTOTAL DECIMAL(5,2)
		SET @VALORTOTAL = (SELECT sum(item.QUANTIDADE_ITEM_PRODUTO * prod.PRODUTO_PRECOUNIT) FROM ITEMPEDIDOS AS item join PRODUTOS AS prod ON item.PRODUTOFK_ITEM = prod.ID_PRODUTO WHERE PEDIDOFK_ITEM = 1);
		INSERT INTO PEDIDOS VALUES (@ID, @VALORTOTAL, @CPF);
	END;


	/* Vamos chamar as procedures e inserir os dados dos clientes */

	SET IDENTITY_INSERT CLIENTES ON
	EXEC cadastrarCliente @CPF = 50, @NOME = 'cesar', @ENDERECO = 'testedeendereco', @TELEFONE = 216;
	EXEC procuraCliente @CPF = 50; 

	EXEC cadastrarCliente @CPF = 5461, @NOME = 'Chris', @ENDERECO = 'endereco2teste', @TELEFONE = 4710;
	EXEC procuraCliente @CPF = 5461;

	EXEC cadastrarCliente @CPF = 546111, @NOME = 'Ruan', @ENDERECO = 'endereco3teste', @TELEFONE = 522221;
	EXEC procuraCliente @CPF = 546111;


	/* Vamos chamar a view de estoque para ver como está
	os insumos antes de fazer um pedido */
	SELECT * FROM ESTOQUE;

	/* Vamos chamar as procedures e inserir os dados de um pedido */
	EXEC anotaItensPedido @IDPROD = 1, @QTDPROD = 1, @IDPED = 1;
	EXEC registraPedido @ID = 1, @CPF = 546111;
	
	/* Vamos chamar as tabelas para ver como está registrado
	os pedidos e itens desses pedidos */
	SELECT * FROM PEDIDOS;
	SELECT * FROM ITEMPEDIDOS;

	/* Por fim, chamamos a procedure de diminuir os insumos
	e vemos como ficou o estoque após o pedido do item
	nesse caso café 1 */
	EXEC abaixaInsumo @CAFE = 1;
	SELECT * FROM ESTOQUE;