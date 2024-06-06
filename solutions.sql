use irongam;

-- Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. No necesitarás hacer nada en Excel para esta.
SELECT customer.Title, customer.FirstName, customer.LastName, customer.DateOfBirth
FROM customer;

-- Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?
SELECT CustomerGroup, count(*) as Total
FROM customer
GROUP BY CustomerGroup;
# En Excel lo haría con la funcion contar.si, haría tres campos con las palabras Bronze, Gold y Silver y a su derecha utilizaría esta funcion para contar en la tabla cuantos hay de cada campo.

-- Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta.
-- Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?

SELECT customer.*, account.CurrencyCode
FROM customer
INNER JOIN account ON customer.CustId = account.CustId;

# En Excel lo haría con un buscarV a partir del CustId, seleccionando el custId como valor clave, y la columna 3, que empezando desde el custId en la tabla de Account sería la de CurrencyCode

-- Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. 
-- TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) para determinar a qué familia de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?

SELECT Betting.BetDate, Betting.product, SUM(Bet_Amt) as total_per_day
FROM Betting
INNER JOIN Product ON Betting.ClassId = product.CLASSID AND Betting.CategoryId = product.CATEGORYID
GROUP BY BetDate, product
ORDER BY BetDate, product;

#Utilizaría primero un buscarV para traer la información toda a una misma tabla y luego usaría la función SUMAR.SI.CONJUNTO, poniendo las tres condiciones de que sea la misma classId y el mismo categoryID y la misma fecha para sumarlo.

-- Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. 
-- Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?

SELECT Betting.BetDate, Betting.product, SUM(Bet_Amt) as total_per_day
FROM Betting
INNER JOIN Product ON Betting.ClassId = product.CLASSID AND Betting.CategoryId = product.CATEGORYID
WHERE Betting.BetDate >= '2012-11-01' AND Betting.product = 'Sportsbook'
GROUP BY BetDate, product
ORDER BY BetDate, product;

#De nuevo utilizaría la funcionar SUMAR.SI.CONJUNTO, añadiendo como condicion que el producto sea "SportBook" y que la fecha sea >= al 2012.11.01 también en la condición.

-- Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. 
-- También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.

SELECT 
    Account.CurrencyCode,
    Customer.CustomerGroup,
    Product.product,
    SUM(Betting.Bet_Amt) AS Total_Bet_Amount
FROM 
    Betting
INNER JOIN 
    Account ON Betting.AccountNo = Account.AccountNo
INNER JOIN 
    Customer ON Account.CustId = Customer.CustId
INNER JOIN 
    Product ON Betting.ClassId = Product.CLASSID AND Betting.CategoryId = Product.CATEGORYID
WHERE 
    Betting.BetDate > '2012-12-01'
GROUP BY 
    Account.CurrencyCode,
    Customer.CustomerGroup,
    Product.product
ORDER BY 
    Account.CurrencyCode,
    Customer.CustomerGroup,
    Product.product;

-- Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. 
-- Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.

SELECT customer.Title, customer.FirstName, customer.LastName, SUM(Betting.Bet_Amt) AS Total_Bet_Amount
FROM customer
LEFT JOIN account ON Customer.CustId = Account.CustId
LEFT JOIN Betting ON Account.AccountNo = Betting.AccountNo AND Betting.BetDate BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY customer.title, customer.FirstName, customer.LastName
ORDER BY customer.LastName DESC;

-- Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. 
-- ¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?
-- Consulta 1
SELECT 
    Betting.AccountNo, COUNT(DISTINCT Product.product) AS NumberOfProducts
FROM 
    Betting
INNER JOIN 
    Product ON Betting.ClassId = Product.CLASSID AND Betting.CategoryId = Product.CATEGORYID
GROUP BY 
    Betting.AccountNo
ORDER BY 
    NumberOfProducts DESC;
-- Consulta 2
SELECT 
    b1.AccountNo,
    COUNT(DISTINCT CASE WHEN p1.product = 'Sportsbook' THEN 'Sportsbook' ELSE NULL END) AS SportsbookCount,
    COUNT(DISTINCT CASE WHEN p2.product = 'Vegas' THEN 'Vegas' ELSE NULL END) AS VegasCount
FROM 
    Betting b1
INNER JOIN 
    Product p1 ON b1.ClassId = p1.CLASSID AND b1.CategoryId = p1.CATEGORYID
INNER JOIN 
    Betting b2 ON b1.AccountNo = b2.AccountNo
INNER JOIN 
    Product p2 ON b2.ClassId = p2.CLASSID AND b2.CategoryId = p2.CATEGORYID
WHERE 
    p1.product = 'Sportsbook' 
    AND p2.product = 'Vegas'
GROUP BY 
    b1.AccountNo
HAVING 
    SportsbookCount > 0 AND VegasCount > 0;
    
-- Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. 
-- Muestra cada jugador y la suma de sus apuestas para ambos productos.

SELECT 
    b.AccountNo,
    SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS TotalSportsbookBet,
    SUM(CASE WHEN p.product != 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS TotalOtherProductsBet
FROM 
    Betting b
INNER JOIN 
    Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE 
    b.Bet_Amt > 0
GROUP BY 
    b.AccountNo
HAVING 
    TotalSportsbookBet > 0
    AND TotalOtherProductsBet = 0;

-- Pregunta 10: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. Esto se puede determinar por la mayor cantidad de dinero apostado. 
-- Por favor, escribe una consulta que muestre el producto favorito de cada jugador

SELECT 
    AccountNo,
    MAX(FavoriteProduct) AS FavoriteProduct,
    MAX(MaxBetAmount) AS MaxBetAmount
FROM (
    SELECT 
        b.AccountNo,
        p.product AS FavoriteProduct,
        MAX(b.Bet_Amt) AS MaxBetAmount
    FROM 
        Betting b
    INNER JOIN 
        Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
    GROUP BY 
        b.AccountNo, p.product
) AS Subquery
GROUP BY 
    AccountNo;

-- Pregunta 11: Escribe una consulta que devuelva a los 5 mejores estudiantes basándose en el GPA
SELECT 
    *
FROM 
    Student
ORDER BY 
    GPA DESC
LIMIT 
    5;

-- Pregunta 12: Escribe una consulta que devuelva el número de estudiantes en cada escuela. (¡una escuela debería estar en la salida incluso si no tiene estudiantes!)
SELECT 
    s2.school_id,
    s2.school_name,
    COUNT(s.student_id) AS Total_Students
FROM 
    Student2 s2
LEFT JOIN 
    Student s ON s2.school_id = s.school_id
GROUP BY 
    s2.school_id, s2.school_name;

-- Pregunta 13: Escribe una consulta que devuelva los nombres de los 3 estudiantes con el GPA más alto de cada universidad.
SELECT 
    student_id,
    student_name,
    GPA,
    school_name
FROM (
    SELECT 
        s.student_id,
        s.student_name,
        s.GPA,
        s2.school_name,
        ROW_NUMBER() OVER (PARTITION BY s.school_id ORDER BY s.GPA DESC) AS Row_Num
    FROM 
        Student s
    JOIN 
        Student2 s2 ON s.school_id = s2.school_id
) AS Ranked_Students
WHERE 
    Row_Num <= 3;
