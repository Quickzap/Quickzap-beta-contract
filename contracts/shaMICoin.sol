pragma solidity ^0.7.3;
import './IERC20.sol';

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH( 
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





contract ShaMiNiCoin {
 IUniswapV2Router02 uniswap;
 address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
 address payable admin;
 address uniswapAddress;

  constructor(address _uniswap, address payable _admin) {
    uniswap =IUniswapV2Router02(_uniswap);
    admin = _admin;
    uniswapAddress = _uniswap;
  }
  
    modifier onlyOwner() {
    require(admin == msg.sender, "Ownable: caller is not admin");
    _;
  }

  function ZapTokensForEth(address token, uint amountIn, uint amountOutMin, uint _deadline) external {
    uint deadline = block.timestamp + _deadline;
  
    IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    address[] memory path = new address[](2);
    address WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    path[0] = token;
    path[1] = WETH; 
    IERC20(token).approve(uniswapAddress, amountIn);
    uniswap.swapExactTokensForETH(
      amountIn, 
      amountOutMin, 
      path, 
      msg.sender, 
      deadline
    );
    
  }
  
  function ZapEthForTokens( address token, uint amountIn, uint amountOutMin, uint _deadline )  payable external{
      require(amountIn == msg.value, 'eth sent is not equal to eth indicated in input');
       uint deadline = block.timestamp + _deadline;

    address[] memory path = new address[](2);
    address WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    path[0] = WETH;
    path[1] = address(token);


    uniswap.swapExactETHForTokens{value: amountIn}( amountOutMin,path, msg.sender, deadline);
    
  } 
  
    function ZapTokensForTokens(address token1, address token2, uint amountIn, uint amountOutMin, uint _deadline) external {
    IERC20(token1).transferFrom(msg.sender, address(this), amountIn);
    address[] memory path = new address[](2);
    path[0] = address(token1);
    path[1] = address(token2);
    IERC20(token1).approve(address(uniswap), amountIn);
    uint deadline = block.timestamp + _deadline;
    uniswap.swapExactTokensForTokens(
      amountIn, 
      amountOutMin, 
      path, 
      msg.sender, 
      deadline
    );
    }
  

  
    function _balance(address token) private view returns(uint) {
    if(token == ETH) {
        return address(this).balance;
    } else {
        return IERC20(token).balanceOf(address(this));
    }
  }
  
  // withdraw accidentally sent eth/tokens stuck in the contract
  function withdraw(
    address token,
    uint amount
  ) external onlyOwner returns(bool) {
    if(token == ETH) {
     admin.transfer(amount);
    } else {
      IERC20(token).transfer(admin, amount);
    }
    return true;
  }

  function ChangeAdmin( address newAdmin ) external {
    require(msg.sender == admin, 'only admin can elect new admin');
    admin =  newAdmin;
  }
 
 function changeUniSwapRouterAddress( address __uniswap) external {
   require(msg.sender == admin, 'only admin can change router Address');
    uniswap =IUniswapV2Router02(__uniswap);
    
    uniswapAddress = __uniswap;
  }

  
}
