//
//  HTFirstViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/14.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTFirstViewController.h"
#import "HTFlickrAPIRequester.h"

@interface HTFirstViewController () <UITableViewDelegate, UITableViewDataSource>
@property HTFlickrAPIRequester *flickrAPIRequester;
@property (strong, nonatomic) IBOutlet UITableView *imagesTableView;
@property NSArray *images;
@end

@implementation HTFirstViewController
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];
    _imagesTableView.delegate = self;
    _imagesTableView.dataSource = self;
    _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    [_flickrAPIRequester authorize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) showImages {
    [_flickrAPIRequester fetchImages:^(NSDictionary *response) {
        NSLog(@"ok");
        NSLog(@"%@", response[@"photos"][@"photo"]);
        _images = [[NSArray alloc] initWithArray:response[@"photos"][@"photo"]];
        //NSLog(@"@%", _images);
//        for (NSObject *photo in response[@"photos"][@"photo"]) {
//            NSLog(@"%@", photo);
//        }
        [_imagesTableView reloadData];
    }];
}

#pragma mark delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_images count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"hoge";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *imageInfo = _images[indexPath.row];
    NSString *urlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg", imageInfo[@"farm"], imageInfo[@"server"], imageInfo[@"id"], imageInfo[@"secret"]];
    //NSLog(urlString);
    NSData *imageData = [NSData dataWithContentsOfURL:
                  [NSURL URLWithString:urlString]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    cell.imageView.image = image;
    cell.textLabel.text = @"hogeho";
    return cell;
}


@end
