#!/usr/bin/perl
# By Miklós Bán at 2015.12.02
# banm@vocs.unideb.hu

# search for directories in the current directory
@list=`find . -maxdepth 1 -type d`;
for ($i=0;$i<@list;$i++) {
    $dir=$list[$i];
    chop $dir;
    if($dir eq '.') {
        next;
    }
    #@files=`find '$dir' -type f -maxdepth 1 -name 'PICT*.JPG'|awk -F / '{print \$2","\$3}'`;
    # search for files in the subdirectories
    @files=`find '$dir' -maxdepth 1 -name 'PICT*.JPG'`;
    @files = sort @files;
    $dir =~ s/ /_/g;
    $csvfile = "$dir.csv";
    print "processing $csvfile\n";
    open(my $fh, ">", "$csvfile") 
    	or die "cannot open > $csvfile: $!";
    printf $fh "name,timestamp,exposure,imgsize,flash,iso,temperature,species,number of inds.,action,detailes,weather\n";
    #print $fh @files;
    for ($j=0;$j<@files;$j++) {
        $pict = $files[$j];
        chop $pict;
        if(-z $pict) {
            next;
        }
        #print "exiv2 '$pict'\n";
        print ".";
        my $temperature = "";
        `convert '$pict' -gravity South  -crop 300x78-250+0 /tmp/test.tif`;
        `tesseract /tmp/test.tif /tmp/test 2>/dev/null`;
        if (-s "/tmp/test.txt") {
            open my $text, '<', "/tmp/test.txt"; 
            $temperature = <$text>; 
            close $text;
            chop $temperature;
            unlink "/tmp/test.txt";
            unlink "/tmp/test.tif";
        }
        @exiv=`exiv2 '$pict'`;
        $exiv[6] =~ /[a-zA-Z ]+: (.+)$/;
        $timestamp = $1;
        $exiv[8] =~ /[a-zA-Z ]+: (.+)$/;
        $exposure = $1;
        $exiv[3] =~ /[a-zA-Z ]+: (.+)$/;
        $imgsize = $1;
        $exiv[0] =~ /[a-zA-Z ]+: (.+)$/;
        $imgname = $1;
        $exiv[11] =~ /[a-zA-Z ]+: (.+)$/;
        $flash = $1;
        $flash =~ s/,/ /g;
        $exiv[15] =~ /[a-zA-Z ]+: (.+)$/;
        $iso = $1;
        printf $fh "%s,%s,%s,%s,%s,%s,%s,,,,,\n",$imgname,$timestamp,$exposure,$imgsize,$flash,$iso,$temperature;
    }
    print "\n";
    close $fh;
}
