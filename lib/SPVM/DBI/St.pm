package SPVM::DBI::St;

1;

=encoding utf8

=head1 Name

SPVM::DBI::St - Statement Handle

=head1 Description

L<DBI::St|SPVM::DBI::St> class in L<SPVM> represents a statement handle. It is used to execute SQL statements and fetch result sets.

=head1 Usage

  use Go::Context;
  my $ctx = Go::Context->background;
  
  # Prepare and execute
  my $sth = $dbh->prepare($ctx, "SELECT id, name FROM users WHERE id = ?");
  $sth->execute($ctx, [(object)1]);
  
  # Fetch data
  while (my $row = $sth->fetchrow_array($ctx)) {
    my $id = $row->[0]->(int);
    my $name = $row->[1]->(string);
  }

=head1 Fields

=head2 Database

C<has Database : ro L<DBI::Db|SPVM::DBI::Db>;>

The database handle that created this statement handle.

=head2 Statement

C<has Statement : ro string;>

The SQL statement string.

=head1 Instance Methods

=head2 option_names

C<protected method option_names : string[] ()>

Returns the valid option names for this statement handle. This method is intended to be overridden in child classes.

=head2 NUM_OF_FIELDS

C<method NUM_OF_FIELDS : int ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns the number of fields (columns) in the result set.

=head2 NAME

C<method NAME : string[] ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns an array of column names.

=head2 NULLABLE

C<method NULLABLE : int[] ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns an array indicating if each column is nullable.

=head2 TYPE

C<method TYPE : int[] ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns an array of column types.

=head2 PRECISION

C<method PRECISION : int[] ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns an array of column precision values.

=head2 SCALE

C<method SCALE : int[] ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns an array of column scale values.

=head2 execute

C<method execute : int ($ctx : L<Go::Context|SPVM::Go::Context>, $bind_values : object[] = undef)>

Executes the prepared statement. Returns the number of affected rows, or -1 if unknown.

=head2 fetchrow_array

C<method fetchrow_array : object[] ($ctx : L<Go::Context|SPVM::Go::Context>)>

Fetches the next row of data. Returns an array of objects or C<undef> if there are no more rows.

=head2 rows

C<method rows : int ($ctx : L<Go::Context|SPVM::Go::Context>)>

Returns the number of rows affected by the last execute.

=head2 finish

C<method finish : void ()>

Indicates that no more data will be fetched from this statement handle.

=head2 DESTROY

C<method DESTROY : void ()>

The destructor. Automatically calls L</"finish">.

=head1 See Also

L<DBI|SPVM::DBI>, L<DBI::Db|SPVM::DBI::Db>, L<Go::Context|SPVM::Go::Context>

=head1 Repository

L<https://github.com/yuki-kimoto/SPVM-DBI>

=head1 Author

Yuki Kimoto C<kimoto.yuki@gmail.com>

=head1 Copyright & License

Copyright (c) 2026 Yuki Kimoto

MIT License
