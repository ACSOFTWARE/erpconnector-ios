//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "ERPCCommon.h"
#import "SideMenuVC.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>


@implementation ACMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.clipsToBounds = YES;
		
		UIView *bgView = [[UIView alloc] init];
		bgView.backgroundColor = [UIColor colorWithHue:0.500 saturation:0.033 brightness:0.286 alpha:1.000];
		self.selectedBackgroundView = bgView;
		
		self.imageView.contentMode = UIViewContentModeCenter;
		
		self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.2f)];
		self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		self.textLabel.textColor = [UIColor colorWithRed:(196.0f/255.0f) green:(204.0f/255.0f) blue:(218.0f/255.0f) alpha:1.0f];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(54.0f/255.0f) green:(61.0f/255.0f) blue:(76.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine];
		
		UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine2.backgroundColor = [UIColor colorWithRed:(54.0f/255.0f) green:(61.0f/255.0f) blue:(77.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine2];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(40.0f/255.0f) green:(47.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:bottomLine];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = CGRectMake(50.0f, 0.0f, 200.0f, 43.0f);
	self.imageView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 43.0f);
}

@end

@implementation ACSideMenuVC

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ACMenuCell";
    
    ACMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ACMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor =  [UIColor colorWithHue:0.500 saturation:0.036 brightness:0.110 alpha:1.000];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"logout.png"];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Znajdź kontrahenta", nil);
            cell.imageView.image = [UIImage imageNamed:@"search.png"];
            break;
            
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Ostatnie", nil);
            cell.imageView.image = [UIImage imageNamed:@"history.png"];
            break;
            
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Ulubione", nil);
            cell.imageView.image = [UIImage imageNamed:@"fav_menu.png"];
            break;
            
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Informacje", nil);
            cell.imageView.image = [UIImage imageNamed:@"info.png"];
            break;

            
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    switch(indexPath.row) {
        case 0:
            [Common Logout];
            break;
        case 1:
            Common.navigationController.viewControllers = [NSArray arrayWithObject:Common.SearchVC];
            break;
        case 2:
            Common.navigationController.viewControllers = [NSArray arrayWithObject:Common.HistoryVC];
            break;
        case 3:
            Common.navigationController.viewControllers = [NSArray arrayWithObject:Common.FavoritesVC];
            break;
        case 4:
            Common.navigationController.viewControllers = [NSArray arrayWithObject:Common.InfoVC];
            break;

            
    }
    

    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
}

 

@end
