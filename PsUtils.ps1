#########console encoding
function utf8          {[Console]::OutputEncoding = [System.Text.Encoding]::UTF8 }
function ascii         {[Console]::OutputEncoding = [System.Text.Encoding]::ASCII}

######Jobs
function start-job-here([scriptblock]$block) { Start-Job -Init ([ScriptBlock]::Create("Set-Location '$pwd'")) -Script $block }
function su            ([scriptblock]$block) {$here = [scriptblock]::Create("cd '$pwd';");Start-Process 'powershell' -ArgumentList '-noexit','-command',$here$block -verb runas }

#####changing working directory
function here { pwd | % { [IO.Directory]::SetCurrentDirectory($_.path) } }

#####Format-XML
Function Format-XML {
    Param(
        [parameter(Mandatory=$true, ValueFromPipeline)][xml] $Xml,
        [parameter(Mandatory=$false)][String] $Indent = 2
    )
    Begin{} 
    Process {
        $StringWriter = New-Object System.IO.StringWriter 
        $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
        $XmlWriter.Formatting = "indented" 
        $XmlWriter.Indentation = $Indent 
        $Xml.WriteContentTo($XmlWriter) 
        $XmlWriter.Flush() 
        $StringWriter.Flush() 
        Write-Output $StringWriter.ToString() 
    }
}

#####Notepad++
function note {
    Param(
        [parameter(ValueFromPipeline)] [System.IO.FileInfo[]]$File,
        [parameter()] [String[]]$FilePath
    )
    Begin {
    }
    Process {
        if ($File) {
            $p = $File.FullName
        } else {
            $p = $FilePath
        }
        & 'C:\Program Files\Notepad++\notepad++.exe' $p
    }
}


#########other utilsy
function logoutwin32   {(Get-WmiObject -Class Win32_OperatingSystem).Win32Shutdown(0)}
function date          {Get-Date -UFormat "%Y-%m-%d"}

function Get-Zip-Items {
	Param(
		[parameter(ValueFromPipeline)] [System.IO.FileInfo[]]$File,
		[parameter()] [String[]]$FilePath
	)
	Begin {
		[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
	}
	Process {
		if ($File) {
			$p = $File.FullName
		} else {
			$p = $FilePath
		}
		[IO.Compression.ZipFile]::OpenRead($p).Entries.FullName
	}
}

function Find-In-Jar {
	Param(
		[parameter()] [String]$ClassName,
		[parameter(ValueFromPipeline)] [System.IO.FileInfo[]]$File,
		[parameter()] [String[]]$FilePath,
		[parameter()] [Switch]$IncludeJarName
	)
	Begin {
		[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
	}
	Process {
		if ($File) {
			$p = $File.FullName
		} else {
			$p = $FilePath
		}
		$Pattern = '*' + ($ClassName -replace '\.','/') + ".class"
		if ($IncludeJarName) {
			Get-Zip-Items -FilePath $p | ? {$_ -like $Pattern} | %{[PSCustomObject]@{JarName=$p; FileName=$_}}
		} else {
			Get-Zip-Items -FilePath $p | ? {$_ -like $Pattern}
		}
	}
}
