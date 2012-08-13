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