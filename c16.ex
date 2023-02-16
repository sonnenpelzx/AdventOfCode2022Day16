defmodule Code16 do
    def formatq16() do
    {:ok, input} = File.read("inputq16.txt")
    rows = input |> String.split("\n")
    rows = Enum.map(rows, fn row -> String.split(row, ["Valve ", " has flow rate=", "; tunnels lead to valves ",  "; tunnel leads to valve ", ", "], trim: true) end)
      rows = Enum.map(rows, fn row -> [src, rate | valves] = row; res = {src, String.to_integer(rate),  Enum.map(valves, fn el -> String.trim(el, "\r")end)}; res end)
    graph = List.foldl(rows,Map.new(),fn row,acc -> Map.put(acc,elem(row,0),%{rate: elem(row,1), nbrs: elem(row,2)}) end)
    graph
  end
  def dijkstras(_, [], visited) do visited end
  def dijkstras(graph, [{elem, dis} | queue], visited) do 
    newVisited = List.flatten(visited, [{elem, dis}])
    {:ok, map} = Map.fetch(graph, elem)
    {:ok, neighbors} = Map.fetch(map, :nbrs)
    {q, v} = List.foldl(neighbors, {queue, newVisited}, fn e, {q, v} -> 
      {:ok, graph} = Map.fetch(graph, e)
      {:ok, rate} = Map.fetch(map, :rate)
      if member?(v, e) or member?(q, e)do
          {q,v}
      else
        {List.flatten(q, [{e, dis + 1}]), v}
      end
    end
    )
   dijkstras(graph, q, v) 
  end
  def member?(visited, elem) do List.foldl(visited, false, fn {e,_}, acc -> 
    if e == elem do
      true
    else
      acc
    end
  end)end

  def getshortest() do 
    graph = formatq16()
    allkeys = Map.keys(graph)
    List.foldl(allkeys, Map.new(), fn elem, acc -> 
      {:ok, map} = Map.fetch(graph, elem)
      {:ok, rate} = Map.fetch(map, :rate)
      if rate != 0  or elem == "AA" do
        Map.put(acc, elem, {dijkstras(graph, [{elem, 0}], []), rate})
      else 
        acc
      end
    end)
  end

  def q16(min) do 
    graph = beautify(getshortest())
    search(graph, "AA", min, 0, List.delete(Map.keys(graph), "AA"))
  end

 
  def q16b(min) do 
    graph = beautify(getshortest())
    player2(graph, "AA", "AA", min,min, 0, List.delete(Map.keys(graph), "AA"),min)
  end

  def getValvePairs(list) do 
    {pairs, _} = List.foldl(list,{[], list}, fn elem, {acc, lis} -> lis = List.delete(lis, elem)
      {List.foldl(lis, acc, fn e, a -> [{elem, e} | a]end), lis}
    end)
    pairs
  end


  def player2_2NB(graph, valveH, valveE, minH, minE, press, closed, min) do 
      valvePairs = getValvePairs(closed)
    List.foldl(valvePairs, 0, fn {h, e}, acc -> 
        removed = List.delete(closed, h)
        {_, rateH} = graph[h]
        {neighH, _} = graph[valveH]
        {_, disH} = List.keyfind(neighH, h, 0)
        minH = minH - 1 - disH
        pressH = minH * rateH
      
        removed = List.delete(removed, e)
        {_, rateE} = graph[e]
        {neighE, _} = graph[valveE]
        {_, disE} = List.keyfind(neighE, e, 0)
        minE = minE - 1 - disE
        pressE = minE * rateE
        {e, minE, pressE, removed}
        
        pressure = player2(graph, h, e, minH, minE, press + pressH + pressE, removed, min - 1)
      if pressure > acc do
        pressure
      else
        acc
      end
    end)
  end

  def player2(_graph, _valveH, _valveE, _minH, _minE, press, _closed, min) when min <= 0 do press end
  def player2(_graph, _valveH, _valveE, _minH, _minE, press,[], _min) do press end
  def player2(graph, valveH, valveE, minH, minE, press,closed, min) do
    cond do
      minH == min -> player2_1NB(graph, valveH, valveE, minH, minE, press, closed, min, true)
      minE == min -> player2_1NB(graph, valveH, valveE, minH, minE, press, closed, min, false)
      true -> player2(graph, valveH, valveE, minH, minE, press, closed, min - 1)
    end
  end

 
  def player2_1NB(graph, valveH, valveE, minH, minE, press, closed, min, person) do 
    {valve1, valve2, min1, min2} = if person do
        {valveH, valveE, minH, minE}
    else
        {valveE, valveH, minE, minH}
    end 
    {:ok, {neighbors, _}} = Map.fetch(graph, valve1)
    neighbors = simplify(neighbors, closed, graph)
    List.foldl(neighbors, 0, fn {neigh, dis}, acc ->
      if Map.has_key?(graph, neigh) and Enum.member?(closed, neigh) do
        removed = List.delete(closed, neigh)
        {_, rate} = graph[neigh]
        minutes = min1 - 1 - dis;
        pressure = player2(graph, neigh,valve2, minutes,min2,minutes * rate, removed, min)
        if pressure > acc do
          pressure
        else
          acc
        end
      else
        acc
      end
    end
      ) + press
  end
  def simplify(list, closed, graph) do
    List.foldl(list, [], fn {elem, dis}=e1, acc -> 
      if Enum.member?(closed, elem) do
        {list, add} = List.foldl(acc, {[], false}, fn {e, d} =e2, {ac, _} -> 
          {_, r1} = graph[elem]
          {_, r2} = graph[e]
          cond do 
            d < dis and r2 > r1 -> {[e2|ac], false}
            d > dis and r2 < r1 -> {ac, true}
            true -> {[e2|ac], true}
          end
        end)
          if add or list == [] do
            [e1 |list]
          else
            list
          end
      else
        acc
      end
    end)
  end
  def beautify(graph) do
    List.foldl(Map.keys(graph), Map.new(), fn elem, acc ->
      {neigh, rate} = graph[elem]
      Map.put(acc, elem, {remove0s(neigh, Map.keys(graph)), rate})
    end)
  end
  def remove0s(neigh, not0s) do 
      List.foldl(neigh, [], fn {n, dis} = nb, acc ->
        if Enum.member?(not0s, n) do
          [{n, dis} | acc]
        else
          acc
        end
      end)
  end 

  def search(_, _, min, press,_) when min <= 0 do press end
  def search(_, _, _, press, []) do press end
  def search(graph, valve, min, press, closed) do
    {:ok, {neighbors, _}} = Map.fetch(graph, valve)
    List.foldl(neighbors, 0, fn {neigh, dis}, acc ->
      if Map.has_key?(graph, neigh) and Enum.member?(closed, neigh) do
        removed = List.delete(closed, neigh)
        {_, rate} = graph[neigh]
        minutes = min - 1 - dis;
        pressure = search(graph, neigh, minutes, press + minutes * rate, removed )
        if pressure > acc do
          pressure
        else
          acc
        end
      else
        acc
      end
    end
      )
  end

end

