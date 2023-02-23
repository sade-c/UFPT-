// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/interfaces/IUriGenerator.sol";
import "../../src/UriGenerator.sol";
import "forge-std/Test.sol";

  contract BaseEngine is Test {
    IUriGenerator internal generator;
    // Scalars
    uint256 internal constant WAD = 1e18;
    uint256 internal testDuration = 1 days;
    uint96 internal testExerciseAmount = 1 ether;

    // Users
    address internal constant ALICE = address(0xA);
    address internal constant BOB = address(0xB);
    address internal constant CAROL = address(0xC);
      function setUp() public virtual {
            generator = new TokenURIGenerator();
      }

    function uri() public    view returns (string memory) {

        IUriGenerator.UriParams memory params = IUriGenerator.UriParams({
            exerciseAsset: ALICE,
            exerciseSymbol: "al",
            exerciseTimestamp: uint40(block.timestamp),
            expiryTimestamp: uint40(block.timestamp + testDuration),
            exerciseAmount: testExerciseAmount
        });
        string memory sade=generator.constructTokenURI(params);
        console.logString(sade);
        return sade;
    }

}
