package SPVM::DBI::Dr;

1;

=encoding utf8

=head1 Name

SPVM::DBI::Dr - Driver Handle

=head1 Description

L<DBI::Dr|SPVM::DBI::Dr> class in L<SPVM> represents a driver handle. This class is a base class for driver handles, and each method is expected to be overridden in child classes like L<DBD::SQLite::Dr|SPVM::DBD::SQLite::Dr>.

=head1 Usage

For Driver Authors:

The following example shows how to implement a specific database driver (DBD) by extending the L<DBI::Dr|SPVM::DBI::Dr> class.

  class DBD::MyDriver::Dr extends DBI::Dr {
    
    # Overriding the connect method
    method connect : DBI::Db ($ctx : Go::Context, $dsn : string, $user : string = undef, $password : string = undef, $options : object[] = undef) {
      
      my $dbh = DBD::MyDriver::Db->new;
      
      # Call the common connection logic provided by the base class.
      # This validates options and stores them into the database handle ($dbh).
      $self->connect_common($dbh, $ctx, $dsn, $user, $password, $options);
      
      # Implement the driver-specific logic to connect to a database.
      # You should apply network-related settings (e.g., TCPNoDelay, ConnectTimeoutDurationNsec) 
      # to the actual socket here.
      # ...
      
      return $dbh;
    }
    
  }

=head1 Instance Methods

=head2 connect

C<method connect : L<DBI::Db|SPVM::DBI::Db> ($ctx : L<Go::Context|SPVM::Go::Context>, $dsn : string, $user : string = undef, $password : string = undef, $options : object[] = undef)>

Establishes a connection to the database specified by the C<$dsn> and returns a database handle (L<DBI::Db|SPVM::DBI::Db>).

The following options can be specified in C<$options>.

=over 4

=item * C<ConnectTimeoutDurationNsec>

The maximum time to wait for the database connection to be established, specified in nanoseconds.

For Driver Authors:

When establishing a connection, you must use this value to set a deadline for the dialer (e.g., C<Go::Net::Dialer>). This ensures that the connection attempt does not hang indefinitely if the database server is unreachable.

=item * C<TCPNoDelay>

A boolean value (0 or 1) to disable Nagle's algorithm. Set to 1 to reduce latency for small packets by sending them immediately.

For Driver Authors:

If this method is not overridden in a child class (a specific DBD), it throws a L<DBI::Error::SQLState|SPVM::DBI::Error::SQLState> exception with SQLSTATE "IM001" (Driver does not support this function) to indicate that the driver implementation is missing.

You must apply this setting to the underlying socket using the C<TCP_NODELAY> option. If this option is not explicitly provided by the user in C<$options>, you should call C<apply_modern_tcp_settings> from L<IO::Socket|SPVM::IO::Socket> to apply optimized defaults.

=item * C<SocketKeepAliveDurationNsec>

The interval for TCP keep-alive probes, specified in nanoseconds. This is useful for maintaining long-lived connections through firewalls or load balancers that might drop idle connections.

For Driver Authors:

You must enable TCP keep-alive on the socket and set the interval using this value. If this option is not explicitly provided by the user, you should call C<apply_modern_tcp_settings> from L<IO::Socket|SPVM::IO::Socket> to ensure reliable default behavior.

=item * C<IdleTimeoutDurationNsec>

The duration a connection can remain idle before it is considered expired and closed by the driver, specified in nanoseconds.

For Driver Authors:

You should use this value to set the C<Timeout> of the L<IO::Socket|SPVM::IO::Socket>. This ensures that the connection is closed if no data is sent or received within the specified duration, preventing resources from being leaked by hung connections.

=item * C<InactiveDestroy>

A boolean value. If set to 1, the C<disconnect> method will not be called automatically when the database handle object is destroyed (C<DESTROY>).

For Driver Authors:

You should set this value to the corresponding field of the database handle object (which should extend L<DBI::Db|SPVM::DBI::Db>). The base class's C<DESTROY> method will automatically check this field to determine whether to call C<disconnect>.

=back

For Driver Authors:

By calling L</"connect_common">, these options are validated and stored in the L<DBI::Db|SPVM::DBI::Db> instance. However, simply storing them in the object is not enough; driver authors are responsible for the actual socket or connection configuration using these stored values.

If this method is not overridden in a child class (a specific DBD), it throws a L<DBI::Error::SQLState|SPVM::DBI::Error::SQLState> exception with SQLSTATE "IM001" (Driver does not support this function) to indicate that the driver implementation is missing.

=head2 connect_common

C<protected method connect_common : void ($dbh : L<DBI::Db|SPVM::DBI::Db>, $ctx : L<Go::Context|SPVM::Go::Context>, $dsn : string, $user : string = undef, $password : string = undef, $options : object[] = undef)>

For Driver Authors:

This method provides common initialization logic for a database handle. It is intended to be called by driver authors within their C<connect> implementation.

This method performs the following tasks:

=over 2

=item 1.

Validates the option names in C<$options> using L<option_names|SPVM::DBI::Db/"option_names">.

=item 2.

Parses the DSN to extract the database name and username.

=item 3.

Sets the L<AutoCommit|SPVM::DBI::Db/"AutoCommit"> field of C<$dbh> to 1.

=item 4.

If an option exists in C<$options>, its value is mapped to the corresponding field in C<$dbh>. The mapped fields include:

=over 2

=item * L<InactiveDestroy|SPVM::DBI::Db/"InactiveDestroy">

=item * L<IdleTimeoutDurationNsec|SPVM::DBI::Db/"IdleTimeoutDurationNsec">

=item * L<ConnectTimeoutDurationNsec|SPVM::DBI::Db/"ConnectTimeoutDurationNsec">

=item * L<ReadTimeoutDurationNsec|SPVM::DBI::Db/"ReadTimeoutDurationNsec">

=item * L<WriteTimeoutDurationNsec|SPVM::DBI::Db/"WriteTimeoutDurationNsec">

=item * L<SocketKeepAliveDurationNsec|SPVM::DBI::Db/"SocketKeepAliveDurationNsec">

=item * L<TCPNoDelay|SPVM::DBI::Db/"TCPNoDelay">

=back

By using C<exists> check internally, this method allows driver authors to distinguish whether a field was explicitly set by the user or should be initialized with a modern default.

=back

=head2 option_names

C<protected method option_names : string[] ()>

For Driver Authors:

Returns an array of supported option names for the database handle.

In the base class L<DBI::Db|SPVM::DBI::Db>, this method returns the following default options:

=over 2

=item * C<InactiveDestroy>

=item * C<IdleTimeoutDurationNsec>

=item * C<ConnectTimeoutDurationNsec>

=item * C<ReadTimeoutDurationNsec>

=item * C<WriteTimeoutDurationNsec>

=item * C<SocketKeepAliveDurationNsec>

=item * C<TCPNoDelay>

=back

Driver authors can override this method to add driver-specific options. These names are used by L<connect_common|SPVM::DBI::Dr/"connect_common"> or L<prepare_common|SPVM::DBI::Db/"prepare_common"> to validate the options provided by the user via L<Fn#check_option_names|SPVM::Fn/"check_option_names">.

=head1 See Also

L<DBI|SPVM::DBI>, L<DBI::Db|SPVM::DBI::Db>, L<Go::Context|SPVM::Go::Context>

=head1 Repository

L<https://github.com/yuki-kimoto/SPVM-DBI>

=head1 Author

Yuki Kimoto C<kimoto.yuki@gmail.com>

=head1 Copyright & License

Copyright (c) 2026 Yuki Kimoto

MIT License
