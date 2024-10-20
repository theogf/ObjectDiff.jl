"Equivalent to the `@test` macro, that will print the difference tree if `@test_diff` is called on an equality call."
macro test_diff(ex, kwargs...)
    if ex isa Expr && ex.head == :call && first(ex.args) in [:(==), :isequal]
        esc(
            quote
                let diff = compare($(ex.args[2]), $(ex.args[3]))
                    if !nodiff(diff)
                        show(stderr, MIME"text/plain"(), diff)
                    end
                    @test $(ex) $(kwargs...)
                end
            end,
        )
    else
        esc(:(@test $(ex)))
    end
end
