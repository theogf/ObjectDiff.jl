macro test_diff(ex)
    if ex isa Expr && ex.head == :call && first(ex.args) == :(==)
        quote
            let diff = compare($(ex.args[2]), $(ex.args[3]))
                if !nodiff(diff)
                    show(stderr, MIME"text/plain"(), diff)
                end
                @test $(ex)
            end
        end
    else
        :(@test $(ex))
    end
end
