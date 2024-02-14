#!/usr/bin/perl

use v5.34;
use strict;
use warnings;
use Term::ExtendedColor qw(:all);

our $run = 1;
my $TITLE = fg('springgreen1', '### CONTACTS APP ###');

#DISPLAYS CONTACTS
sub showContacts{
    open FILE, "contactsheet.txt";
    chomp (my @contacts = <FILE>);
    close FILE;
    @contacts = sort (@contacts);
    print fg('springgreen1', "\nYOUR CONTACTS\n\n");
    my $i = 1;

    foreach (@contacts){
        my @info = split /::/, $_;                          #spliting raw lines on '::' char, saving each element in the @info arr
        say "$i. $info[0] - $info[1] - $info[2]";
        $i++;
    }
}

#ADDS 1 NEW CONTACT
sub addContact{
    say "you selected add contact!";
    my $ii = fg('red1', 'INVALID INPUT');

    my $name = nameFormatter();

    my $num = numFormatter();

    my $eAdd = emailFormatter();

    my $newContact = "$name\::$num\::$eAdd";
    open FILE, ">>contactsheet.txt";
    print FILE "$newContact\n";                             #">>" is APPENDING a new entry into the existing doc, along with a \n char 
    close FILE;
    print fg('springgreen1', "\nNew contact added!\n");
}

#FORMATS NEW NAME ENTRIES
sub nameFormatter{
    my $ii = fg('red1', 'INVALID INPUT');
    print "\nEnter your contact's first and last name: ";
    chomp (my $name = <STDIN>);
    until ($name =~ /\A[a-zA-Z-]+\s+[a-zA-Z-]+\Z/){         #checking for valid input [firstname lastname]
        print "$ii - Please enter a first and last name: ";
        chomp ($name = <STDIN>);
    }
    $name =~ s/([a-zA-Z-]+)\s*/\u\L$1 /g;                   #Capitalizing 1st chars of name
    $name = substr($name, 0, -1);

    return($name);
}
#FORMATS NEW NUMBER ENTRIES
sub numFormatter{
    print "\nEnter your contact's phone number: ";
    my $ii = fg('red1', 'INVALID INPUT');
    chomp (my $num = <STDIN>);
    until ($num =~ /\A(\d{3})?\D?\d{3}\D?\d{4}\Z/){         #checing for valid input [10 or 7 digit phone number, with out without dashes]
        print "$ii - Please enter a valid phone number: ";
        chomp ($num = <STDIN>);
    }
    if (length$num > 9){
        $num =~ s/(\d{3}).?(\d{3}).?(\d{4})/$1-$2-$3/;      #ensuring proper phoneNumber format [111-222-3333]
    }else{
        $num =~ s/(\d{3}).?(\d{4})/$1-$2/;
    }

    return($num);
}
#FORMATS NEW EMAIL ENTRIES
sub emailFormatter{
    print "\nEnter your contact's email address: ";
    my $ii = fg('red1', 'INVALID INPUT');
    chomp (my $eAdd = <STDIN>);
    until ($eAdd =~ /\A.+@.+\..+/){
        print "$ii - Please enter a valid Email Address: ";
        chomp ($eAdd = <STDIN>);
    }

    return($eAdd);
}

#SEARCHES EXISTING CONTACTS, GENERAL SEARCH OR SPECIFIC SEARCH (for DELETING or EDITING)
sub searchContacts{
    open FILE, "contactsheet.txt";
    chomp (my @contacts = <FILE>);
    close FILE;
    my $searchTerm;
    my $searchChecker = -1;

    if($_[0]){  #------------------------------------------#If an argument is passed to &searchContacts, it enables EXACT SEACH and returns it for removal/editing
        print "Enter the EXACT NAME of your desired contact: ";
        chomp ($searchTerm = <STDIN>);

        foreach (@contacts){
            if ($_ =~ /\A($searchTerm)::/i){
                my @info = split /::/, $_;
                say "\n$info[0] - $info[1] - $info[2]";
                return ($_, $info[0]);
            }else{
                $searchChecker ++;
            }
        }
    }else{ #-----------------------------------------------#no argument passed results in a general serach of contacts
        print "Search your contacts by name: ";
        chomp ($searchTerm = <STDIN>);
        print "\n";

        my $i = 1;
        foreach (@contacts){
            if ($_ =~ /\A$searchTerm/i){
                my @info = split /::/, $_;
                say "$i. $info[0] - $info[1] - $info[2]";
                $i++;
            }else{
                $searchChecker ++;
            }
        }
    }

    if ($searchChecker == $#contacts){
        print fg('pink1', "\nSorry, Couldn't find the contact \"$searchTerm\"\n");
        return('null');
    }
}

#REMOVE AN EXISTING CONTACT
sub removeContact{
    my $searchChecker = -1;
    my $unwantedTerm;
    my $name;
    my $deleteChoice;

    if ($_[0]){
        $unwantedTerm = $_[0];
        $deleteChoice = 'y';
    }else{
        say "You chose to Delete a contact";
        ($unwantedTerm, $name) = searchContacts(1);
        return() if $unwantedTerm eq 'null';

        print "\nAre you sure you'd like to delete \"$name\"? [y/n]: ";
        chomp ($deleteChoice = <STDIN>);
    }
    if ($deleteChoice =~ /\Ay/i){
        open FILE, "<contactsheet.txt";
        my @file = <FILE>;
        close (FILE);
        open (FILE, ">contactsheet.txt");
        foreach my $line (@file){
            print FILE $line unless ($line =~ /$unwantedTerm/);
        }
        close (FILE);

        print fg('springgreen1', "\n$name Sucessfully deleted\n") unless ($_[0]);
    }else{
        say "\nDeletion Terminated";
        return();
    }
}

#EDIT 1 FIELD OF AN EXISTING CONTACT
sub editContact{
    say "You chose to edit a contact";
    my ($desired_line, $name) = searchContacts(1);
    return() if $desired_line eq 'null';

    my @info = split /::/, $desired_line;

    say "Would you like edit the Name(1), Number(2), or email(3)?";
    print "Enter your choice: ";
    chomp (my $choice = <STDIN>);

    until ($choice =~ /[1-3]/){
        print  fg("red1", "\nPlease enter the number corresponding with your choice: ");
        chomp ($choice = <STDIN>);
    }

    if ($choice == 1){
        $info[0] = nameFormatter
    }elsif ($choice == 2){
        $info[1] = numFormatter;
    }elsif ($choice == 3){
        $info[2] = emailFormatter;
    }

    removeContact($desired_line);                           #removing the old contact from the doc

    my $newContact = "$info[0]\::$info[1]\::$info[2]";
    open FILE, ">>contactsheet.txt";
    print FILE "$newContact\n";                             #">>" is APPENDING a new entry with the updated info into the existing doc
    close FILE;
    print fg('springgreen1', "\n$info[0] updated successfully!\n");
}

#PROVIDE A CHOICE TO QUIT OR RETURN TO MAIN MENU AFTER EACH SUB
sub quitter{
    #these 2 lines are just formatting/coloring for STDOUT
    my $ltrQ = fg('red1', "\'q\'"); my $enter = fg('springgreen1', "\'Enter\'");
    print fg ('pink1', "\nEnter $ltrQ") . fg('pink1', " to quit, or press $enter") . fg('pink1', " to return to main menu: ");

    chomp (my $exit = <STDIN>);
    if ($exit =~ /\Aq/i){
        return(0);
    }else{
        return(1);
    }
}

while ($run == 1){
    printf "%48s\n", "$TITLE";
    say "MAIN MENU:\n1. Display your contacts\n2. Search your contacts\n3. Add a new contact\n4. Edit an existing contact\n5. Delete an existing contact\n0. Quit program\n";
    print fg('pink1', "Enter your choice: ");
    chomp (my $usrChoice = <STDIN>);

    until ($usrChoice =~ /[0-5]/){
        print  fg("red1", "\nPlease enter the number corresponding with your choice: ");
        chomp ($usrChoice = <STDIN>);
    }

    if ($usrChoice == 1){
        showContacts;
        $run = quitter;
        print "\n";
    }elsif ($usrChoice == 2){
        searchContacts;
        $run = quitter;
        print "\n";
    }elsif ($usrChoice == 3){
        addContact;
        $run = quitter;
        print "\n";
    }elsif ($usrChoice == 4){
        editContact;
        $run = quitter;
        print "\n";
    }elsif ($usrChoice == 5){
        removeContact;
        $run = quitter;
        print "\n";
    }elsif ($usrChoice == 0){
        $run = 0;
    }
}
