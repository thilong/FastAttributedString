# FastAttributedString
Fast create NSAttributedString

#Usage:
--------
    _label.attributedText = [NSAttributedString fast:@"This is a [*#730000 14*]TEST[**]. Org style. [*#008899 24*]by -Thilong."];
   
######Support color ,font size , and custom font. to use custom font, you should use "fast:defaultFont:defaultColor:registedFont" like this:
---------
    _label.attributedText = [NSAttributedString fast:@"This is a [*#730000 FMB*]TEST[**]. Org style. [*#008899 24*]by -Thilong."
                                         defaultFont:_label.font
                                        defaultColor:_label.textColor
                                        registedFont:@{
                                                       @"FMB" : [UIFont boldSystemFontOfSize:32]
                                                       }
                             ];
