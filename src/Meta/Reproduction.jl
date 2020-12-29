module Reproduction


function CAWS(current, other...; brood_size=3)
    averages = mean.(eachrow(hcat(current, other...)))
    make_sol(averages) = [rand() < chance for chance in averages]
    unique([make_sol(averages) for _ in 1:brood_size])
end

function GA(a, b)
    i = rand(1:length(a))
    vcat(a[1:i], b[i+1:end])
end

function jaya(current, better, worse)

end

function jaya_simp(current::BitArray, better, worse)

end

function jaya_trad(current::BitArray, better, worse)

end

function TBO(current::BitArray, best, mean)

end

function CBO(current, worst, mean)

end

function LBO()

end

function Rao1()

end

function Rao2()

end


function mutate()

end


end
