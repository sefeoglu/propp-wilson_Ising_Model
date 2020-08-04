using Pkg; Pkg.activate("."); Pkg.instantiate()
using Distributions, LinearAlgebra
using Plots; pyplot(); default(legendfontsize = 15.0, linewidth = 2.0)
using Random
function InitialState(N)  # Generates an initial state with all values fixed to +1 and -1 ---OK
    state = zeros(3, N, N)
    for i in 1:N
        for j in 1:N
            state[1, i, j] = 1
            state[2, i, j] = -1
        end
    end
    return state
end
function calcEnergyDiff(i, j, state)  # Calculate the energy at flipping the vertex at [i,j]
    m = size(state, 2)
    if i == 1
        top = 1
    else
        top = state[i - 1, j]
    end
    if i == m
        bottom = 1
    else
        bottom = state[i + 1, j]
    end
    if j == 1
        left = 1
    else
        left = state[i, j - 1]
    end
            
    if j == m
        right = 1
    else
        right = state[i, j + 1]
    end

    energy = 2 * state[i,j] * sum([top, bottom, left, right])  # Energy calculated by given formula
                
    return energy
end
    
function updateState(t, state, U,T)
    B = 1 / T
    E = zeros(3)

    i = Int(U[2,Int(-t)])  # Picks a random vertex, the same each time the chain runs from 0
    j = Int(U[3,Int(-t)])
    
    for h in 1:3

        E[h] =  calcEnergyDiff(i, j, state[h,:,:])  # Find energy under randomly generated flip of each state space separately

        u = U[1,Int(-t)]
        if state[h, i, j] == 1
            u = 1 - u
        end
        
        if u < 0.5 * (1 - tanh(0.5 * B * E[h]))  # condition to accept change, random number is the same each time
            state[h, i, j] = -state[h, i, j]
            #n[h]=1
        else
            state[h, i, j] = state[h, i, j]
            #n[h]=0
        end
    end

    return state  # returns both states
end
function runIsing(t, state, U, T)  # Runs chain from the designated starting time until time 0

    while t < 0
        state = updateState(t, state, U,T)
        t += 1
    end
    return state
end
function genRandomness(N, M)  # generate and store three sets of random numbers
    U = zeros(3, M)

    U[2,:] = rand(1:N, M) # Random numbners i
    U[3,:] = rand(1:N, M)  # Random numbners j
    for i in 1:M
        U[1,i] = rand()  # Random numbners U
    end
    return U
end
function genStartingTimes(j)  # Creates starting times, each one is double the previous
    M = zeros(j)
    M[2] = 1
    for x in 3:j
        M[x] = 2 * M[x - 1]
    end       
    return M
end
function runProppWilson(N,j,T)
    M = genStartingTimes(j)# negative integers (-1,-2,-4,-8)
    U = genRandomness(N, 1)# U0,U1,U2...
    state = InitialState(N)
    m=2
    mag_list = zeros(N)# for plotting of magnetization
    while state[1,:,:] != state[2,:,:]  # Condition for termination: both state spaces are the same
        U = hcat(U,genRandomness(N, Int(M[m] - M[m-1]))) # Generates more random numbers when necessary
        
        magnetization = sum([sum(i) for i in state[1,:,:]])-sum([sum(i) for i in state[2,:,:]])
        
        println("magnetization= ",magnetization, "round= ", m)
        mag_list[m-1] = magnetization
        state = runIsing(-Int(M[m]), state,U, T)
        m += 1  # If states are not the same, goes to the next starting time
        
    end
    
    return state[1,:,:],mag_list
    
end
function Graph(N, j, T)
    state, magnetization = runProppWilson(N, j,T)
end
