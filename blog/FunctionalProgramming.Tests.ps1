function New-ImmutableObject($object) {
    $immutable = New-Object PSObject

    $object.Keys | %{ 
        $value = $object[$_]
        $closure = { $value }.GetNewClosure()
        $immutable | Add-Member -name $_ -memberType ScriptProperty -value $closure
    }
    
    return $immutable
}

Describe "Immutable Object" {
    It "Should create immutable object" {
        $immutable = New-ImmutableObject @{ Name = "test"}
        $immutable.Name.Should.Be("test")

        try {
           $immutable.Name = "test1"
           $false.Should.Be($true)
        }
        catch [System.Management.Automation.SetValueException] {
            $true.Should.Be($true)
        }
    }
}

function Convert-ByFilter($values, $predicate) {
    return $values | where { & $predicate $_ }
}

Describe "Higher Order Functions" {
    $values = @(1, 2, 3, 4)

    It "Should filter even" {
        $evenPredicate = { param($value) return $value % 2 -eq 0 }
        $even = Convert-ByFilter $values $evenPredicate
        $even.Length.Should.Be(2)
        $even[0].Should.Be(2)
        $even[1].Should.Be(4)
    }

    It "Should filter odd" {
        $oddPredicate = { param($value) return $value % 2 -eq 1 }
        $odd = Convert-ByFilter $values $oddPredicate
        $odd.Length.Should.Be(2)
        $odd[0].Should.Be(1)
        $odd[1].Should.Be(3)
    }
}

Describe "Currying" {
    It "Should add two values via annonymous functions" {
        $add = { param($x) return { param($y) return $x + $y }.GetNewClosure() }
        $addFive = & $add 5
        $ten = & $addFive 5
        $ten.Should.Be(10)

        $ten = & (& $add 5) 5
        $ten.Should.Be(10)
    }

    It "Should add two values via named functions" {
        function add($x) { return { param($y) return $y + $x }.GetNewClosure() }
        $addFive = add 5

        $ten = & $addFive 5
        $ten.Should.Be(10)

        $ten = & (add 5) 5
        $ten.Should.Be(10)
    }
}

Describe "Lazy" {
    $function = [System.Func[string]] { return "test" }
    $lazy = New-Object System.Lazy[string] $function

    It "Should not have a value evaluated" {
        $lazy.IsValueCreated.Should.Be($false)
    }

    It "Should get lazy value" {
        $lazy.Value.Should.Be("test")
        $lazy.IsValueCreated.Should.Be($true)
    }
}