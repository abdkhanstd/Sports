function [BW,maskedImage] = mysegment(RGB)
%segmentImage Segment image using auto-generated code from imageSegmenter app
%  [BW,MASKEDIMAGE] = segmentImage(RGB) segments image RGB using
%  auto-generated code from the imageSegmenter app. The final segmentation
%  is returned in BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 10-Sep-2019
%----------------------------------------------------


% Convert RGB image into L*a*b* color space.
X = rgb2lab(RGB);

% Graph cut
foregroundInd = [24137 24321 24413 24416 24417 24418 24419 24420 24421 24422 24423 24424 24505 24516 24597 24600 24608 24689 24693 24700 24781 24786 24787 24788 24792 24873 24880 24884 24965 24973 24976 25061 25068 25149 25157 25160 25241 25245 25249 25252 25333 25337 25429 25433 25436 25517 25521 25525 25609 25613 25614 25615 25616 25620 25701 25705 25712 25793 25797 25798 25804 25885 25889 25890 25896 25977 25981 25982 25988 26068 26069 26073 26074 26079 26160 26171 26252 26263 26344 26436 26444 26445 26446 26447 26528 26532 26533 26534 26535 26621 26622 26623 26713 ];
backgroundInd = [96 188 372 740 924 1985 2084 2087 2122 2360 2369 2530 2651 3087 3202 3227 3483 3552 3652 3731 3940 3963 4314 4331 4361 4364 4367 4368 4372 4515 4607 4643 4682 4746 4791 4955 5108 5159 5217 5231 5280 5418 5527 5684 5869 5895 5931 6079 6246 6332 6355 6427 6477 6493 6631 6723 7068 7219 7275 7328 7531 7610 7615 7619 7624 7735 7755 7756 7844 7850 7863 7919 7936 7955 8011 8039 8173 8195 8445 8471 8488 8509 8563 8655 8747 8787 8790 8796 8806 8839 9115 9160 9253 9391 9437 9438 9461 9462 9593 9622 9667 9714 9724 9733 9943 9992 10311 10361 10472 10587 10793 10931 11205 11415 11535 11660 11815 11837 12006 12014 12021 12023 12104 12703 12887 12979 13163 13311 13505 13589 13623 13695 13899 14158 14359 14415 14618 14875 14964 15095 15151 15170 15422 15423 15424 15463 15555 15604 15605 15696 15709 15720 15739 15806 15808 15810 15879 15969 16107 16243 16712 16882 17395 17431 17556 17648 17737 17926 18013 18131 18161 18295 18387 18557 18565 18683 18749 18939 18959 18985 19020 19120 19205 19301 19304 19307 19513 19676 19681 19685 19777 19862 19883 19900 19958 19960 19961 20083 20231 20712 20911 21358 21463 21634 21727 21794 22094 22105 22833 23208 23290 23388 23480 23481 23841 24100 24392 24748 24840 24942 25126 25218 25310 25403 25666 25865 26142 26327 26492 26567 26570 26578 26879 26950 27025 27135 27246 27301 27318 27338 27410 27502 27613 27669 27854 28041 28042 28043 28044 28071 28225 28254 28317 28438 28501 28530 28685 28779 28870 28899 29636 29790 30068 30188 30464 30623 30647 30716 30807 30808 30899 30988 31015 31446 31745 31837 32021 32090 32297 32458 32481 33126 33310 33563 33954 34024 34138 34414 34506 34874 34950 35058 35506 35518 35598 35690 35964 36162 36345 36805 36897 37247 37265 37540 37908 38000 38274 38351 38550 38734 39010 39179 39378 39456 39642 39643 39654 39826 40008 40010 40192 40284 40576 40842 41026 41212 41304 41488 41764 42126 42141 42399 42491 42877 43324 43612 43888 44065 44072 44164 44348 44435 44527 44803 44903 45261 45273 45900 46288 46816 47092 47118 47185 47462 47738 48106 48381 48682 48837 49569 49660 49844 49969 50400 50772 51051 51160 51601 51784 51896 52172 52332 52448 52724 52789 53063 53247 53339 53368 53428 53430 53644 53697 53828 54329 54472 54599 54600 54784 54786 54883 55023 55067 55253 55759 55812 55904 55996 56364 56772 57100 57374 57647 57879 58155 58247 58466 58615 58831 59659 59998 60307 60773 61379 61617 61991 62209 62833 63018 63110 63198 63467 63648 64190 64329 64736 64791 64883 65068 65105 65291 65344 65570 65663 65939 65988 66214 67000 67314 68048 68323 68376 68507 68691 68925 69291 69567 69616 69845 69985 70029 70030 70077 70122 70215 70353 70720 70956 71081 71353 71631 71728 72349 72486 72766 72859 72906 72944 73115 73292 73475 73659 73843 73931 ];
L = superpixels(X,480,'IsInputLab',true);

% Convert L*a*b* range to [0 1]
scaledX = prepLab(X);
BW = lazysnapping(scaledX,L,foregroundInd,backgroundInd);

% Fill holes
BW = imfill(BW, 'holes');

% Invert mask
BW = imcomplement(BW);

% Invert mask
BW = imcomplement(BW);

% Create masked image.
maskedImage = RGB;
maskedImage(repmat(~BW,[1 1 3])) = 0;
end

function out = prepLab(in)

% Convert L*a*b* image to range [0,1]
out = in;
out(:,:,1) = in(:,:,1) / 100;  % L range is [0 100].
out(:,:,2) = (in(:,:,2) + 86.1827) / 184.4170;  % a* range is [-86.1827,98.2343].
out(:,:,3) = (in(:,:,3) + 107.8602) / 202.3382;  % b* range is [-107.8602,94.4780].

end