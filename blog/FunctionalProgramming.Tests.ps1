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

function New-Lazy($script) {
    $function = [System.Func[object]] $script
    $lazy = New-Object System.Lazy[object] $function

    return $lazy
}

Describe "Lazy" {
    $lazy = New-Lazy { return "test" }

    It "Should not have a value evaluated" {
        $lazy.IsValueCreated.Should.Be($false)
    }

    It "Should get lazy value" {
        $lazy.Value.Should.Be("test")
        $lazy.IsValueCreated.Should.Be($true)
    }
}

Describe "Pattern Matching" {
    It "Should use a simple switch" {
        $a = 5
        $result = switch ($a) { 
            1 {"The colour is red."} 
            2 {"The colour is blue."} 
            3 {"The colour is green."} 
            4 {"The colour is yellow."} 
            5 {"The colour is orange."} 
            6 {"The colour is purple."} 
            7 {"The colour is pink."}
            8 {"The colour is brown."} 
            default {"The colour could not be determined."}
        }

        $result.Should.Be("The colour is orange.") 
    }

    It "Should use a wildcard switch" {
        $a = "d14151"

        $result = switch -wildcard ($a) { 
            "a*" {"The colour is red."} 
            "b*" {"The colour is blue."} 
            "c*" {"The colour is green."} 
            "d*" {"The colour is yellow."} 
            "e*" {"The colour is orange."} 
            "f*" {"The colour is purple."} 
            "g*" {"The colour is pink."}
            "h*" {"The colour is brown."} 
            default {"The colour could not be determined."}
        }

        $result.Should.Be("The colour is yellow.") 
    }

    It "Should use a regex switch" {
        $a = "r14151"

        $result = switch -regex ($a) { 
            "[a-d]" {"The colour is red."} 
            "[e-g]" {"The colour is blue."} 
            "[h-k]" {"The colour is green."} 
            "[l-o]" {"The colour is yellow."} 
            "[p-s]" {"The colour is orange."} 
            "[t-v]" {"The colour is purple."} 
            "[w-y]" {"The colour is pink."}
            "[z]" {"The colour is brown."} 
            default {"The colour could not be determined."}
        }

        $result.Should.Be("The colour is orange.") 
    }
}