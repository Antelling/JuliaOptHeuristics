using JuMP

m1 = [2, 6, 8, 9, 15, 21, 24, 25, 29, 44, 60, 66, 70, 85, 87, 94, 118, 185, 202, 209, 210, 217, 223, 226, 258,282, 293, 302, 331, 341, 366, 375, 395, 399, 405, 406, 444, 446, 453, 467, 476, 509, 513, 598, 643,644, 660, 690, 698, 713, 714, 745, 746, 773, 793, 794, 808, 809, 818, 822, 828, 836, 860, 863, 870, 890]
m2 = [5, 38, 42, 58, 62, 65, 67, 112, 121, 131, 149, 151, 158, 184, 200, 201, 205, 206, 211, 219, 230, 287,303, 344, 359, 390, 429, 441, 450, 466, 479, 498, 541, 551, 553, 557, 558, 588, 591, 606, 617, 620,646, 650, 658, 693, 695, 701, 712, 723, 733, 741, 742, 747, 756, 784, 791, 830, 850, 851, 852]
m3 = [1, 12, 45, 55, 63, 110, 116, 129, 169, 178, 179, 198, 199, 249, 254, 261, 278, 279, 309, 310, 326, 327,351, 354, 362, 364, 381, 387, 389, 397, 408, 430, 443, 482, 492, 535, 552, 585, 587, 595, 611, 625,637, 711, 728, 731, 738, 759, 787, 800, 824, 832, 835, 840, 844, 893, 895]
m4 = [33, 41, 49, 53, 81, 98, 108, 119, 146, 154, 155, 177, 180, 203, 222, 227, 231, 250, 270, 283, 286, 328,338, 347, 363, 368, 373, 382, 383, 384, 393, 412, 452, 472, 503, 530, 561, 571, 581, 602, 628, 630,633, 634, 663, 665, 717, 721, 732, 740, 748, 763, 775, 781, 788, 812, 857, 861, 877, 881, 888, 898]
m5 = [40, 50, 61, 88, 107, 130, 138, 161, 168, 176, 207, 221, 224, 241, 275, 277, 290, 297, 298, 304, 321,335, 342, 361, 378, 415, 418, 426, 431, 470, 518, 527, 548, 564, 603, 615, 626, 651, 653, 670, 675,689, 716, 719, 778, 819, 820, 834, 845, 847, 862, 882]
m6 = [27, 34, 36, 39, 52, 71, 79, 122, 128, 132, 134, 143, 183, 193, 208, 232, 233, 236, 301, 308, 311, 316,323, 337, 343, 358, 367, 391, 403, 404, 421, 447, 448, 460, 465, 477, 500, 532, 572, 580, 601, 607,609, 618, 638, 639, 648, 649, 657, 672, 704, 749, 802, 846, 854, 871, 883, 889]
m7 = [23, 32, 64, 68, 80, 95, 135, 162, 172, 196, 228, 239, 244, 247, 259, 268, 276, 281, 318, 325, 356, 392,396, 401, 414, 461, 480, 506, 522, 525, 539, 542, 559, 599, 613, 624, 629, 654, 656, 669, 687, 696,699, 735, 744, 762, 766, 796, 811, 817, 827, 839, 884, 900]
m8 = [17, 20, 37, 46, 48, 51, 57, 103, 106, 152, 187, 188, 237, 245, 253, 264, 285, 332, 352, 353, 369, 379,424, 433, 462, 468, 473, 475, 485, 502, 511, 514, 529, 556, 567, 573, 574, 577, 582, 590, 610, 635,641, 645, 671, 678, 685, 707, 729, 730, 753, 755, 758, 774, 777, 780, 810, 843, 849, 856, 864, 876,880, 886, 896]
m9 = [3, 14, 35, 54, 73, 74, 104, 109, 117, 133, 137, 142, 145, 150, 160, 170, 171, 173, 204, 213, 215, 220,234, 238, 272, 284, 313, 333, 340, 355, 372, 428, 435, 451, 454, 478, 483, 487, 494, 524, 534, 537,547, 562, 570, 586, 605, 622, 659, 667, 679, 686, 703, 727, 736, 768, 792, 803, 866, 867, 875, 891]
m10 = [7, 59, 77, 82, 83, 102, 123, 139, 140, 147, 164, 174, 197, 216, 248, 263, 265, 271, 291, 295, 299, 312,336, 345, 365, 374, 398, 413, 419, 425, 439, 504, 507, 520, 521, 526, 533, 560, 565, 575, 604, 619,655, 662, 676, 677, 680, 691, 697, 705, 725, 737, 754, 757, 779, 816, 841, 887]
m11 = [10, 26, 31, 43, 76, 90, 92, 105, 120, 127, 156, 167, 181, 191, 255, 306, 307, 315, 334, 349, 357, 371,409, 420, 456, 459, 463, 508, 512, 517, 519, 528, 554, 578, 623, 631, 640, 642, 664, 681, 694, 722,734, 743, 752, 770, 782, 786, 789, 790, 798, 799, 804, 807, 815, 821, 825, 842, 848, 853, 865, 869, 879]
m12 = [28, 30, 78, 86, 91, 141, 153, 157, 165, 166, 175, 189, 195, 242, 246, 273, 280, 288, 296, 300, 314, 317,320, 324, 329, 339, 348, 350, 370, 394, 402, 423, 436, 437, 438, 445, 488, 495, 499, 516, 544, 549,555, 566, 569, 596, 597, 627, 652, 682, 683, 688, 706, 708, 710, 760, 765, 769, 785, 795, 813, 833,858, 874, 897]
m13 = [4, 11, 13, 18, 19, 22, 84, 96, 97, 101, 114, 124, 136, 148, 194, 229, 235, 252, 322, 346, 416, 417, 440,486, 489, 491, 501, 505, 510, 531, 536, 540, 550, 579, 583, 584, 593, 600, 612, 616, 632, 661, 673,692, 702, 720, 724, 750, 764, 767, 783, 797, 805, 814, 831, 838, 855, 873]
m14 = [16, 47, 69, 72, 89, 93, 100, 115, 125, 126, 144, 163, 186, 190, 192, 212, 214, 218, 225, 243, 256, 257,260, 262, 267, 289, 292, 305, 319, 330, 360, 376, 377, 380, 385, 386, 410, 427, 469, 471, 481, 490,493, 523, 543, 545, 546, 563, 608, 621, 647, 684, 715, 751, 761, 771, 859, 885, 892, 899]
m15 = [56, 75, 99, 111, 113, 159, 182, 240, 251, 266, 269, 274, 294, 388, 400, 407, 411, 422, 432, 434, 442,449, 455, 457, 458, 464, 474, 484, 496, 497, 515, 538, 568, 576, 589, 592, 594, 614, 636, 666, 668,674, 700, 709, 718, 726, 739, 772, 776, 801, 806, 823, 826, 829, 837, 868, 872, 878, 894]

function make_unsparse(indexes, length)
    z = zeros(length)
    for i in indexes
        z[i] = 1
    end
    z
end

mu(x) = make_unsparse(x, 900)
sol = hcat(mu.([m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15])...)
solt = collect(transpose(sol))

include("../src/JOH.jl")
include("../GAP/GAP.jl")


prob = GAP.load_folder()[31]
model = GAP.create_MIPS_model(prob)
model[:x] = sol
optimize!(model)
termination_status(model)
objective_value(model)


all(sum(sol, dims=2) .== 1)
used_res = sum(prob.job_agent_resource .* sol, dims=1)
all([prob.agents_resource_cap[i] >= used_res[i] for i in 1:15])
sum(prob.job_agent_cost .* sol)