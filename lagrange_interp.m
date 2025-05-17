function y_interp = lagrange_interp(x_vals, y_vals, x)
    n = length(x_vals);
    y_interp = 0;
    for i = 1:n
        L = 1;
        for j = 1:n
            if i ~= j
                L = L * (x - x_vals(j)) / (x_vals(i) - x_vals(j));
            end
        end
        y_interp = y_interp + y_vals(i) * L;
    end
end
