### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 97e18b69-4eb6-42a9-beef-04697156a7ab
using PlutoUI, JuMP

# ╔═╡ 2f845732-c095-11eb-14e8-57175fb5038e
lines = readlines(open("./benchmark_problems/Class B/INST13.txt"))

# ╔═╡ 12f3987f-ea86-46a2-852f-65ce5886cbe2
split_line(line) = filter(x->x!="", split(line, " "))

# ╔═╡ 2c521bfc-683b-4337-b62e-a5586d3d06cb
function parse_int(i)
	try 
		parse(Int, i)
	catch ArgumentError
		parse(Int, replace(i, ".00"=>""))
	end
end

# ╔═╡ d4175f5d-d4e9-4862-9c60-83a74af1dc1c
parse_line(line) = map(n->parse_int(n), split_line(line))

# ╔═╡ 0707ad63-038b-4b0f-9c48-310502701915
file = map(parse_line, lines[2:end])

# ╔═╡ dca8d05b-f878-4fb6-bb8e-cef62dd2249a
m_blocks, n_rows, n_groups = file[1]

# ╔═╡ f1d972de-aa4a-4e5e-91d6-890bd4b21fcd
groups_bounds_row = file[2]

# ╔═╡ 75894d1c-b1c4-4050-8b52-19d837e2bc31
data = file[3:end]

# ╔═╡ cf5f3e19-7087-4e67-bb3e-d02e2b33efeb
block_start_index(i) = (i-1)*(n_rows+1) + 1

# ╔═╡ dc9221b9-09b8-48e9-b46b-8cad6cb0b778
@bind row Slider(1:n_groups)

# ╔═╡ 39ba33bb-7113-4f35-9f19-676178e210cb
n_groups

# ╔═╡ c9fe0f02-8f6a-4584-88ca-d0640fab9be2
n_i = n_rows 

# ╔═╡ 2ef7e159-9bff-4b36-92a3-52c43db1c8fe
m = n_groups

# ╔═╡ d7205749-58ab-4831-8797-ac3d7a175f37
falses(m)

# ╔═╡ c06e268b-09a2-482f-98fa-6ecbd8ee9fe1
n = m_blocks # size of set of disjoint groups

# ╔═╡ 9c4c419c-0517-4ae9-9a48-7368444085fe
function load_block(i, n_groups, data)
	d = data[block_start_index(i):block_start_index(i+1)-1]
	@assert first(first(d)) == i
	items = d[2:end]
	#exactly one of each element in this group must be turned on 
	#in order to represent this in MPS form, we need to one-hot encode the class index
	index = falses(n_groups)
	index[i] = true 
	
	#then combine the one-hot encoding with the resource requirements
	resource_reqs = map(x->vcat(x[2:end], index), items)
	
	#strip the profit vector, then return the (profit, resources) tuple
	profit = map(x->first(x), items)
	profit, resource_reqs
end

# ╔═╡ 1c10debb-ee04-45e2-81fc-9fe4d9362bc7
current_block = load_block(row, n_groups, data)

# ╔═╡ e764cd4e-fc74-4561-8265-e303b2892c88
length(current_block)

# ╔═╡ 8652e037-b90b-4044-a618-730f1f554b2e
function make_model(profit, resource_reqs, available_res)
	m = Model()
	x = @variable(m, x[1:length(profit)])
	add_resource_constraint(m, x, r, a) = 
		@constraint(m, sum(x .* r) <= a)
	map((i, row)->add_resource_constraint(m, x, row, a[i]), resource_reqs)
	@objective(m, Max, sum(x .* profit))
	m
end

# ╔═╡ d3938ef5-e05a-47c3-b4c6-bc966245acd8
blocks = map(i->load_block(i, n_groups, data), 1:n_groups)

# ╔═╡ c35b78db-1c40-4313-a580-83f48680a7e1
profits = vcat(map(b->first(b), blocks)...)

# ╔═╡ 1db24586-4b11-4b75-bfee-1015644527de
resource_reqs = vcat(map(b->b[2], blocks)...)

# ╔═╡ 8fd748aa-6aff-4dcc-a5fd-c50d52295dc5
resource_limits = vcat(groups_bounds_row..., ones(n_groups))

# ╔═╡ Cell order:
# ╠═2f845732-c095-11eb-14e8-57175fb5038e
# ╠═12f3987f-ea86-46a2-852f-65ce5886cbe2
# ╠═d4175f5d-d4e9-4862-9c60-83a74af1dc1c
# ╠═2c521bfc-683b-4337-b62e-a5586d3d06cb
# ╠═0707ad63-038b-4b0f-9c48-310502701915
# ╠═dca8d05b-f878-4fb6-bb8e-cef62dd2249a
# ╠═f1d972de-aa4a-4e5e-91d6-890bd4b21fcd
# ╠═75894d1c-b1c4-4050-8b52-19d837e2bc31
# ╠═cf5f3e19-7087-4e67-bb3e-d02e2b33efeb
# ╠═1c10debb-ee04-45e2-81fc-9fe4d9362bc7
# ╠═d7205749-58ab-4831-8797-ac3d7a175f37
# ╠═dc9221b9-09b8-48e9-b46b-8cad6cb0b778
# ╠═39ba33bb-7113-4f35-9f19-676178e210cb
# ╠═e764cd4e-fc74-4561-8265-e303b2892c88
# ╠═c9fe0f02-8f6a-4584-88ca-d0640fab9be2
# ╠═2ef7e159-9bff-4b36-92a3-52c43db1c8fe
# ╠═c06e268b-09a2-482f-98fa-6ecbd8ee9fe1
# ╠═9c4c419c-0517-4ae9-9a48-7368444085fe
# ╠═8652e037-b90b-4044-a618-730f1f554b2e
# ╠═d3938ef5-e05a-47c3-b4c6-bc966245acd8
# ╠═c35b78db-1c40-4313-a580-83f48680a7e1
# ╠═1db24586-4b11-4b75-bfee-1015644527de
# ╠═8fd748aa-6aff-4dcc-a5fd-c50d52295dc5
# ╠═97e18b69-4eb6-42a9-beef-04697156a7ab
