#import "ViewController.h"



@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *filteredContactsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化 UISearchBar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.searchBar.delegate = self;
    
    //初始化搜索结果数组
    self.filteredContactsArray = [NSMutableArray array];
                                  
    // 将搜索框添加到导航栏上
    self.navigationItem.titleView = self.searchBar;
    
    // 设置搜索栏的外观
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"搜索联系人";
    
    // 注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    
    // 创建UITableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    
    

    
    //创建导航栏右上角的添加按钮
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    self.navigationController.navigationBar.backgroundColor = [UIColor greenColor];
    
    
    // 初始化通讯录数据数组
    self.contactsArray = [[NSMutableArray alloc] init];
    

    
}
#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // 清空搜索结果数组
    [self.filteredContactsArray removeAllObjects];
    
    // 进行模糊搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@ OR phoneNumber CONTAINS[c] %@", searchText, searchText];
    self.filteredContactsArray = [NSMutableArray arrayWithArray:[self.contactsArray filteredArrayUsingPredicate:predicate]];
    
    // 刷新UITableView
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //判断是否在搜索状态
    if(self.searchBar.text.length > 0){
        return self.filteredContactsArray.count;
    }else{
    
    return self.contactsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //获取联系人数据
    NSDictionary *contact;
    if (self.searchBar.text.length > 0){
        contact = self.filteredContactsArray[indexPath.row];
    }else{
        contact = self.contactsArray[indexPath.row];
    }
    
    cell.backgroundColor = [UIColor blackColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    
    // 在单元格中显示联系人姓名
    
    cell.textLabel.text = contact[@"name"];
    cell.detailTextLabel.text = contact[@"phoneNumber"];
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //获取选中的单元格的索引
    NSInteger row = indexPath.row;
    
    //获取选中的联系人数据
    NSDictionary *contact = self.contactsArray[row];
    NSString *name = contact[@"name"];
    NSString *phoneNumber = contact[@"phoneNumber"];
    NSString *email = contact[@"email"];
    
    //创建弹窗
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"联系人详情" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //添加姓名、手机号和邮箱的信息
    NSString *message = [NSString stringWithFormat:@"姓名: %@ \n手机号: %@\n 邮箱：%@", name, phoneNumber, email];
    [alert setMessage:message];
    
    //添加确定按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:confirmAction];
    
    //添加编辑按钮
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //弹出编辑联系人的弹窗
        [self showEditContactAlertWithContact:contact atIndex:row];
    }];
    [alert addAction:editAction];
    
    //添加删除按钮
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //删除联系人数据
        [self.contactsArray removeObjectAtIndex:row];
        
        //对联系人数组进行排序
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.contactsArray = [NSMutableArray arrayWithArray:[self.contactsArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        
        //刷新UITableView
        [self.tableView reloadData];
    }];
    [alert addAction:deleteAction];
    
    //展示弹窗
    [self presentViewController:alert animated:YES completion:nil];
    
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    }

#pragma mark - Helper Methods
//创建编辑的弹窗
- (void)showEditContactAlertWithContact:(NSDictionary*)contact atIndex:(NSInteger)index{
    // 创建弹窗
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"编辑联系人" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加姓名输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"姓名";
        textField.text = contact[@"name"];
    }];
    
    // 添加电话号码输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"电话号码";
        textField.keyboardType = UIKeyboardTypePhonePad;
        textField.text = contact[@"phoneNumber"];
    }];
    
    //添加邮箱输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"邮箱";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.text = contact[@"email"];
    }];
    
    // 添加确定按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 获取输入的联系人姓名和电话号码
        NSString *name = alert.textFields[0].text;
        NSString *phoneNumber = alert.textFields[1].text;
        NSString *email = alert.textFields[2].text;
        
        //更新联系人数据
        NSDictionary *updatedContact = @{@"name": name, @"phoneNumber": phoneNumber, @"email": email};
        [self.contactsArray replaceObjectAtIndex:index withObject:updatedContact];
        
        //对联系人数组进行排序
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.contactsArray = [NSMutableArray arrayWithArray:[self.contactsArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        // 刷新UITableView
        [self.tableView reloadData];
    }];
    [alert addAction:confirmAction];
    
    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    
    // 显示弹窗
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Button Action

-(void)addButtonClicked{
    
    // 创建弹窗
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加联系人" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加姓名输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"姓名";
    }];
    
    // 添加电话号码输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"电话号码";
        textField.keyboardType = UIKeyboardTypePhonePad;
    }];
    
    //添加邮箱输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"邮箱";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    // 添加确定按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 获取输入的联系人姓名和电话号码
        NSString *name = alert.textFields[0].text;
        NSString *phoneNumber = alert.textFields[1].text;
        NSString *email = alert.textFields[2].text;
        
        // 创建联系人字典
        NSDictionary *contact = @{@"name": name, @"phoneNumber": phoneNumber , @"email": email};
        
        
        // 将联系人添加到通讯录数据数组中
        [self.contactsArray addObject:contact];
        
        //对联系人数组进行排序
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.contactsArray = [NSMutableArray arrayWithArray:[self.contactsArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        // 刷新UITableView
        [self.tableView reloadData];
    }];
    [alert addAction:confirmAction];
    
    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    
    // 显示弹窗
    [self presentViewController:alert animated:YES completion:nil];
    
    
}






@end
