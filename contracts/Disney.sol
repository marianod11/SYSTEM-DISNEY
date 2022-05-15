// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}


interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf (address account) external view returns (uint256);
    function allowance(address owner,address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferencia_disney(address sender, address recipient, uint256 amount) external returns (bool);
    function approve (address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Basic is IERC20 {
    string public constant name = "ERC20Basic";
    string public constant symbol = "JBJ-TOKEN";
    uint8 public constant decimals = 2;
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    mapping (address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;
    uint256 totalSupply_;
    
    using SafeMath for uint256;
    
    constructor (uint256 total) public{
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }
    
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    
    function increaseTotalSuply(uint newTokens) public{
        totalSupply_ += newTokens;
        balances[msg.sender] += newTokens;
    }
    
    function balanceOf (address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender,receiver,numTokens);
        return true;
    } 
    
    function transferencia_disney(address sender, address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[sender]);
        balances[sender] = balances[sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(sender,receiver,numTokens);
        return true;
    } 
    
    function approve (address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance (address owner, address delegate) public override view returns (uint){
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require (numTokens <= balances[owner]);
        require (numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner,buyer,numTokens);
        return true;
    }
    
}


contract disney {

    //instancia token
    ERC20Basic private token ;

    address payable public owner;


    constructor() public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }


    //almacenar datos clientes
    struct cliente {
        uint token_comprados;
        string [] atraccacions_disfrutadas;
    }


    //mapping registro clientes
    mapping(address=> cliente) public Clientes;


    //------------------ gestion de tokenss!!!!! --------------------

    //precio del token

    function precioToken(uint _numToken) internal pure returns(uint){
        return _numToken * (1 ether) ;
    }

    //comprar tokens disney

    function comprarTokens(uint _numToken) public payable {
        //precio del token
        uint coste = precioToken(_numToken);
        // se evalua el dinero que el cliente paga por los tokens
        require(msg.value >= coste, "compra menos tokens o paga con mas ethers");
        // deiferencia de lo que paga el cliente
        uint returnValue = msg.value - coste ;
        //disner retorarna la cantidad al cliente
        msg.sender.transfer(returnValue);
        // obtencion tokens disponible.
        uint balance = balanceOf();
        require(_numToken <= balance, "compra menos tokenss");
        //se trasnfiere tokens
        token.transfer(msg.sender, _numToken);
        //registro token comprados
        Clientes[msg.sender].token_comprados = _numToken;

    }
    //balance contrato disney
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }


    //visutalizar tokens restantes cliente
    function misToken() public view returns(uint){
        return token.balanceOf(msg.sender);
    }


    //generara mas tokens
    function generarTokens(uint _numToken) public Unicomente(msg.sender){
        token.increaseTotalSuply(_numToken);
    }

    modifier Unicomente (address _direccion){
        require(_direccion == owner);
        _;
    }


    //-------------- gestions de atracciones --------------------


    //eventos

    event disfruta_atracciones(string, uint, address);
    event nuevas_atracciones(string, uint);
    event baja_atracciones(string);
    event nueva_comida (string, uint, bool);
    event baja_comida (string);
    event disfruta_comida(string, uint, address);

    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }

    //mappin atracciones y struc de datos

    mapping (string => atraccion) public mappingAtracciones;

    //alamecenar atracciones
    string [] Atracciones;

    //mappind clientes con su hisotrial

    mapping (address=> string[]) HistorialAtracciones;

    //crear atracciones
    function crearAtracciones(string memory _nombreAtracciones, uint _precio) public Unicomente(msg.sender) {
        //crear atraccion
        mappingAtracciones[_nombreAtracciones] = atraccion(_nombreAtracciones, _precio, true );
        Atracciones.push(_nombreAtracciones);

        emit nuevas_atracciones(_nombreAtracciones, _precio);
    }


    // dar de bajo atracciones

    function darDeBaja(string memory _nombreAtracciones) public Unicomente(msg.sender){
        // cambiar el estadp de la atraccion
        mappingAtracciones[_nombreAtracciones].estado_atraccion = false;
        emit baja_atracciones(_nombreAtracciones);
    }


    //visualizar atracciones
    function atraccionesDisponilbes() public view returns (string [] memory ){
        return Atracciones;
    }


    //funcion para subir atraccion

    function subirAtraccion (string memory _nombreAtracciones) public {
        //precio atraccion
        uint tokens_atraccion = mappingAtracciones[_nombreAtracciones].precio_atraccion;
        //verificar estado de la atraccion
        require(mappingAtracciones[_nombreAtracciones].estado_atraccion == true, "la atraccion no esta disponible");

        //verificar numero de tokens
        require(tokens_atraccion <= misToken(), "necesitas mas tokenssss");
        //trasferir tokens
        token.transferencia_disney(msg.sender, address(this), tokens_atraccion);
        //alamcenamiento historial de atracciones
        HistorialAtracciones[msg.sender].push(_nombreAtracciones);

        emit disfruta_atracciones(_nombreAtracciones, tokens_atraccion, msg.sender);
    }


    //hisotrial de atracciones cliente

    function historial() public view returns(string [] memory){
        return HistorialAtracciones[msg.sender];
    }


    //devolucion de tokens

    function devolverEntrada(uint _numToken) public payable {
        //el num de token positivo
        require(_numToken > 0, "necesitas mas tokens");
        //el usuario tiene q tener los tojkens
        require(_numToken <= misToken(), "no tienens los tokennnss q desasrr");
        //el clientre devuelve los tokenss
        token.transferencia_disney(msg.sender , address(this), _numToken);
        //devolvucion de los ethers
        msg.sender.transfer(precioToken(_numToken));
    }


    //-------------- comidas disney ----------------

    //mappin comida y struc de datos
    struct comida {
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
    }

    

    mapping (string => comida) public mappingComida;

    //alamecenar comida
    string [] Comida;

    //mappind clientes con su hisotrial

    mapping (address=> string[]) HistorialComida;

    function nuevaComida(string memory _nombreComida, uint _precioComida) public Unicomente(msg.sender) {
        mappingComida[_nombreComida] =  comida(_nombreComida, _precioComida, true);

        Comida.push(_nombreComida);

        emit nueva_comida(_nombreComida, _precioComida, true);

    }

    function darDeBajaComida(string memory _nombreComida) public Unicomente(msg.sender){
        // cambiar el estadp de la atraccion
        mappingComida[_nombreComida].estado_comida = false;
        emit baja_comida(_nombreComida);
    }

    function comidasDisponilbes() public view returns (string [] memory ){
        return Comida;
    }


    function comprarComida (string memory _nombreComida) public {
        //precio atraccion
        uint tokens_atraccion = mappingComida[_nombreComida].precio_comida;
        //verificar estado de la atraccion
        require(mappingComida[_nombreComida].estado_comida == true, "la atraccion no esta disponible");

        //verificar numero de tokens
        require(tokens_atraccion <= misToken(), "necesitas mas tokenssss");
        //trasferir tokens
        token.transferencia_disney(msg.sender, address(this), tokens_atraccion);
        //alamcenamiento historial de atracciones
        HistorialAtracciones[msg.sender].push(_nombreComida);

        emit disfruta_comida(_nombreComida, tokens_atraccion, msg.sender);
    }


    //--------- retirar etherr -------------------



    function retirarTodosEther() public payable Unicomente(msg.sender) {
        (bool success, ) = msg.sender.call{value:address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function balanceEth() public  view returns(uint){
        return address(this).balance;
    }

    function retirarEther(uint _numToken) public payable Unicomente(msg.sender) {
       require (_numToken > 0, "necesitas mas tokenss");
        require(_numToken <= misToken(), "nos tienesn los tokens q quieres devolver");

        token.transferencia_disney(msg.sender, address(this), _numToken);

        msg.sender.transfer(precioToken(_numToken));
    }

}   


