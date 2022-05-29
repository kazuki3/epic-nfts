// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' />";
    
    string[] firstWords = [unicode"ざぶりざぶり", unicode"朝立や", unicode"秋深き", unicode"赤とんぼ", unicode"くろがねの", unicode"赤い椿"];
    string[] secondWords = [unicode"ざぶり雨降る", unicode"馬のかしらの", unicode"隣は何を", unicode"筑波に雲も", unicode"秋の風鈴", unicode"白い椿と"];
    string[] thirdWords = [unicode"枯野かな", unicode"天の川", unicode"する人ぞ", unicode"なかりけり", unicode"鳴りにけり", unicode"落ちにけり"];

    // 57５原文 
    // ざぶりざぶり ざぶり雨降る 枯野かな 小林一茶
    // 朝立や 馬のかしらの 天の川 内藤鳴雪
    // 秋深き 隣は何を する人ぞ 松尾芭蕉
    // 赤とんぼ 筑波に雲も なかりけり 正岡子規
    // くろがねの 秋の風鈴 鳴りにけり　 飯田蛇笏
    // 赤い椿 白い椿と 落ちにけり 河東碧梧桐

    constructor() ERC721 ("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract.");
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pickRandomFirstWord(uint tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        console.log("rand - seed: ", rand);
        rand = rand % firstWords.length;
        console.log("rand - first - word: ", rand);
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function createSvgFirstText(string memory word) internal pure returns (string memory) {
        return string(abi.encodePacked("<text x='40%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>", word, "</text>"));
    }

    function createSvgSecondText(string memory word) internal pure returns (string memory) {
        return string(abi.encodePacked("<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>", word, "</text>"));
    }

    function createSvgThirdText(string memory word) internal pure returns (string memory) {
        return string(abi.encodePacked("<text x='60%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>", word, "</text>"));
    }

    function makeAnEpicNFT() public {
        uint newItemId = _tokenIds.current();

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);

        string memory firstText = createSvgFirstText(first);
        string memory secondText = createSvgSecondText(second);
        string memory thirdText = createSvgThirdText(third);
    
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        string memory finalSvg = string(abi.encodePacked(baseSvg, firstText, secondText, thirdText, "</svg>")); 

        console.log("\n----- SVG data -----");
        console.log(finalSvg);
        console.log("--------------------\n");

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("\n----- Token URI -----");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, finalTokenUri);

        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        _tokenIds.increment();
    }
}