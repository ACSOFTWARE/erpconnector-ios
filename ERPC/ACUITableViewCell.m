//
//  ACUITableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 12.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@implementation ACUITableViewCell {
    id _record;
    BOOL _selectMode;
    BOOL _record_selected;
}

@synthesize delegate;

-(void)setRecord:(id)record {
    _record = record;
}

-(id)record {
    return _record;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _record_selected = false;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(BOOL)selectMode {
    return _selectMode;
}

-(void)setSelectMode:(BOOL)selectMode {
    _selectMode = selectMode;
}

-(void)setRecord_selected:(BOOL)record_selected {
    
    self.accessoryType = record_selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    _record_selected = record_selected;

}

-(BOOL)record_selected {
    return _record_selected;
}

@end
